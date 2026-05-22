import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_provider.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class FindItResult {
  final String placeId;
  final String name;
  final String address;
  final double rating;
  final int ratingsTotal;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String? photoReference;
  final List<String> types;

  double distanceM = 0;
  double communityScore = 0; // computed smart score

  FindItResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.rating,
    required this.ratingsTotal,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.photoReference,
    required this.types,
  });

  factory FindItResult.fromJson(Map<String, dynamic> j) {
    final geo = j['geometry']?['location'];
    final photos = j['photos'] as List<dynamic>?;
    return FindItResult(
      placeId: j['place_id'] ?? '',
      name: j['name'] ?? 'İsimsiz',
      address: j['vicinity'] ?? j['formatted_address'] ?? '',
      rating: ((j['rating'] ?? 0.0) as num).toDouble(),
      ratingsTotal: (j['user_ratings_total'] as int?) ?? 0,
      isOpen: (j['opening_hours']?['open_now'] as bool?) ?? true,
      latitude: geo != null ? (geo['lat'] as num).toDouble() : 0,
      longitude: geo != null ? (geo['lng'] as num).toDouble() : 0,
      photoReference: photos?.isNotEmpty == true ? photos![0]['photo_reference'] as String? : null,
      types: List<String>.from(j['types'] ?? []),
    );
  }

  String get distanceLabel {
    if (distanceM < 1000) return '${distanceM.round()} m';
    return '${(distanceM / 1000).toStringAsFixed(1)} km';
  }

  String get reviewLabel {
    if (ratingsTotal == 0) return 'Yorum yok';
    if (ratingsTotal >= 1000) return '${(ratingsTotal / 1000).toStringAsFixed(1)}B kişi önerdi';
    return '$ratingsTotal kişi önerdi';
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

enum FindItSortType { communityScore, distance }

class FindItScreen extends StatefulWidget {
  const FindItScreen({super.key});
  @override
  State<FindItScreen> createState() => _FindItScreenState();
}

class _FindItScreenState extends State<FindItScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<FindItResult> _results = [];
  List<FindItResult> _allResults = [];
  bool _loading = false;
  FindItSortType _sortType = FindItSortType.communityScore;
  bool _hasSearched = false;
  String? _error;

  static const List<Map<String, String>> _quickTags = [
    {'label': 'Boşnak böreği', 'icon': '🥙'},
    {'label': 'Simit', 'icon': '🥨'},
    {'label': 'Tatlı', 'icon': '🍰'},
    {'label': 'Eczane', 'icon': '💊'},
    {'label': 'ATM', 'icon': '💳'},
    {'label': 'Çay bahçesi', 'icon': '☕'},
    {'label': 'Kuaför', 'icon': '✂️'},
    {'label': 'Pastane', 'icon': '🎂'},
    {'label': 'Fırın', 'icon': '🍞'},
    {'label': 'Market', 'icon': '🛒'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  // ── Topluluk Skoru ────────────────────────────────────────
  // score = (rating/5) × log10(reviews+1) / (distanceKm + 0.3)
  // Yüksek puan + çok yorum + yakın = üstte
  double _calcScore(FindItResult r) {
    if (r.distanceM == 0) return 0;
    final distKm = r.distanceM / 1000;
    final ratingNorm = r.rating / 5.0;
    final reviewWeight = math.log(r.ratingsTotal + 1) / math.ln10;
    return (ratingNorm * reviewWeight) / (distKm + 0.3);
  }

  void _applySorting() {
    if (_sortType == FindItSortType.communityScore) {
      _allResults.sort((a, b) => b.communityScore.compareTo(a.communityScore));
    } else {
      _allResults.sort((a, b) => a.distanceM.compareTo(b.distanceM));
    }
    _results = _allResults.take(15).toList();
  }

  // ── Query Doğrulama ────────────────────────────────────────
  // Türkçe küfürler, kişi isimleri ve saçma girişleri engelle
  static const List<String> _blockedWords = [
    'amk', 'oç', 'göt', 'sik', 'orospu', 'piç', 'yarrak', 'çük', 'ibne',
    'pezevenk', 'kahpe', 'memeli', 'fuck', 'shit', 'ass', 'bitch',
    'bok', 'taşak', 'döl', 'salak', 'aptal', 'gerizekalı', 'gerzek',
  ];

  // Yaygın Türkçe erkek/kadın isimleri — kişi ismi girilmesini engelle
  static const List<String> _commonFirstNames = [
    'melih', 'ödev', 'ahmet', 'mehmet', 'mustafa', 'ali', 'hasan', 'hüseyin',
    'ibrahim', 'ismail', 'yılmaz', 'yıldız', 'can', 'cem', 'emre', 'murat',
    'fatma', 'ayşe', 'emine', 'hatice', 'zeynep', 'meryem', 'esra', 'elif',
    'kemal', 'adem', 'selim', 'serkan', 'burak', 'berk', 'enes', 'furkan',
    'gülseren', 'zehra', 'seda', 'pelin', 'buse', 'irem', 'dilan', 'gül',
    'ramazan', 'bayram', 'ömer', 'yüsuf', 'bekir', 'hıdır', 'nuri', 'necati',
    'selin', 'melis', 'deniz', 'doruk', 'arda', 'kerem', 'ozan', 'orhan',
  ];

  // Yaygın Türkçe soyisimler
  static const List<String> _commonLastNames = [
    'ödev', 'yılmaz', 'kaya', 'demir', 'Şehin', 'çelik', 'yıldız', 'güneş',
    'arslan', 'doğan', 'taş', 'korkmaz', 'aydın', 'güler', 'yıldırım',
    'polat', 'er', 'erşan', 'uslu', 'koç', 'kılıç', 'özdemir', 'öztürk',
    'çetin', 'şahin', 'bulut', 'gündüz', 'kurt', 'aslan', 'ateş', 'simsek',
  ];

  // Türkçe sesli harfler
  static const String _turkishVowels = 'aeıioöuüAEIİOÖUÜ';

  /// Kişi ismi pattern’ini tespit et:
  /// "ad soyad" ya da sadece bilinen isim/soyisim varsa engelle
  bool _looksLikePersonName(String q) {
    final lower = q.toLowerCase().trim();
    final words = lower.split(RegExp(r'\s+'));

    // Tüm kelimeler üstüste isim/soyisim listesinde
    int nameHits = 0;
    for (final w in words) {
      if (_commonFirstNames.contains(w) || _commonLastNames.contains(w)) {
        nameHits++;
      }
    }
    // İki kelimeyse ikisi de isim/soyisim — kişi ismi
    if (words.length == 2 && nameHits == 2) return true;
    // Tek kelimeyse ama bilinen isim listesindeyse
    if (words.length == 1 && _commonFirstNames.contains(words[0])) return true;
    return false;
  }

  bool _isValidQuery(String q) {
    // Min 3 karakter
    if (q.length < 3) return false;

    // Küfür/uygunsuz kelime kontrolü
    final lower = q.toLowerCase();
    for (final word in _blockedWords) {
      if (lower.contains(word)) return false;
    }

    // Kişi ismi mi? ("melih ödev" gibi)
    if (_looksLikePersonName(q)) return false;

    // Saçma yazı tespiti: sesli/toplam oranı çok düşüklse
    final vowelCount = q.split('').where((c) => _turkishVowels.contains(c)).length;
    final ratio = vowelCount / q.length;
    if (q.length >= 4 && ratio < 0.15) return false; // %15’ten az sesli = anlamsız

    // Sadece rakam/sembol
    if (RegExp(r'^[0-9\s\W]+$').hasMatch(q)) return false;

    return true;
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Geçerlilik kontrolü
    if (!_isValidQuery(trimmed)) {
      setState(() {
        _loading = false;
        _hasSearched = true;
        _error = 'Lütfen anlamlı bir şey yaz 🙂\nMesela: "baklava", "eczane", "berber"';
        _results = [];
      });
      return;
    }

    final provider = context.read<AppProvider>();
    final pos = provider.currentPosition;
    if (pos == null) {
      setState(() => _error = 'Konum alınamadı. Konum iznini kontrol edin.');
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _hasSearched = true;
      _error = null;
      _results = [];
    });

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=${Uri.encodeComponent(trimmed)}'
        '&location=${pos.latitude},${pos.longitude}'
        '&radius=8000'
        '&language=tr'
        '&key=${AppConstants.googleMapsApiKey}',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final rawList = (data['results'] as List<dynamic>?) ?? [];
          final results = rawList
              .map((r) => FindItResult.fromJson(r as Map<String, dynamic>))
              .toList();

          for (final r in results) {
            r.distanceM = _haversine(pos.latitude, pos.longitude, r.latitude, r.longitude);
            r.communityScore = _calcScore(r);
          }

          _allResults = results;
          _applySorting();

          setState(() {
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'Sonuç bulunamadı (${data['status']})';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu. Tekrar deneyin.';
        _loading = false;
      });
    }
  }

  Future<void> _openMaps(FindItResult r) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${r.latitude},${r.longitude}');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildQuickTags(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.smallShadow),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nereden Bulurum?', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              Text(_sortType == FindItSortType.communityScore ? 'Topluluk skoruna göre sıralı' : 'Mesafeye göre sıralı', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textTertiary)),
            ]),
          ),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.accentShadow),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.cardShadow),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.textPrimary),
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Boşnak böreği, baklava, eczane...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppTheme.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () { _controller.clear(); setState(() { _results = []; _hasSearched = false; }); },
                          child: const Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _search(_controller.text),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.accentShadow),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 350.ms, delay: 50.ms).fadeIn(duration: 350.ms, delay: 50.ms);
  }

  Widget _buildDisclaimerBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Veriler eski olabilir. Gitmeden önce arayarak teyit et!',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.warning, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildQuickTags() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _quickTags.length,
          itemBuilder: (context, i) {
            final tag = _quickTags[i];
            return GestureDetector(
              onTap: () { _controller.text = tag['label']!; _search(tag['label']!); },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.smallShadow),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tag['icon']!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(tag['label']!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ]),
              ),
            ).animate()
              .slideX(begin: 0.3, duration: 300.ms, delay: Duration(milliseconds: 100 + i * 40))
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 + i * 40));
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();
    if (!_hasSearched) return _buildEmptyState();
    if (_results.isEmpty) return _buildNoResults();
    return _buildResults();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.accentShadow),
          child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
        ),
        const SizedBox(height: 16),
        Text('Topluluk önerileri taranıyor...', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 32)),
          const SizedBox(height: 16),
          Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _search(_controller.text),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.accentShadow), child: Text('Tekrar Dene', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600))),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.accentShadow),
            child: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text('Ne arıyorsun?', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Boşnak böreği, baklava, eczane...\nen çok önerilen yeri bulalım.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textTertiary), textAlign: TextAlign.center),
        ]),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Sonuç bulunamadı', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Farklı anahtar kelime dene\nyakınında olmayabilir', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textTertiary), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Text('${_results.length} mekan bulundu', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.3)),
              const Spacer(),
              PopupMenuButton<FindItSortType>(
                initialValue: _sortType,
                onSelected: (val) {
                  setState(() {
                    _sortType = val;
                    _applySorting();
                  });
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Row(children: [
                  Icon(_sortType == FindItSortType.communityScore ? Icons.groups_rounded : Icons.near_me_rounded, size: 14, color: AppTheme.accent),
                  const SizedBox(width: 4),
                  Text(_sortType == FindItSortType.communityScore ? 'Topluluk Skoru' : 'Mesafe (En Yakın)', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.accent),
                ]),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FindItSortType.communityScore,
                    child: Row(children: [
                      Icon(Icons.groups_rounded, size: 18, color: _sortType == FindItSortType.communityScore ? AppTheme.accent : AppTheme.textTertiary),
                      const SizedBox(width: 8),
                      Text('Topluluk Skoru', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: _sortType == FindItSortType.communityScore ? FontWeight.w700 : FontWeight.w500, color: _sortType == FindItSortType.communityScore ? AppTheme.accent : AppTheme.textSecondary)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: FindItSortType.distance,
                    child: Row(children: [
                      Icon(Icons.near_me_rounded, size: 18, color: _sortType == FindItSortType.distance ? AppTheme.accent : AppTheme.textTertiary),
                      const SizedBox(width: 8),
                      Text('Mesafe (En Yakın)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: _sortType == FindItSortType.distance ? FontWeight.w700 : FontWeight.w500, color: _sortType == FindItSortType.distance ? AppTheme.accent : AppTheme.textSecondary)),
                    ]),
                  ),
                ],
              ),
            ]),
          );
        }
        if (i == _results.length + 1) {
          return _buildDisclaimerBanner();
        }
        return _buildResultCard(_results[i - 1], i - 1);
      },
    );
  }

  Widget _buildResultCard(FindItResult r, int index) {
    final isTop = index == 0;
    final photoUrl = r.photoReference != null
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photo_reference=${r.photoReference}&key=${AppConstants.googleMapsApiKey}'
        : null;

    return GestureDetector(
      onTap: () => _openMaps(r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isTop ? AppTheme.accentShadow : AppTheme.cardShadow,
          border: isTop ? Border.all(color: AppTheme.accent.withValues(alpha: 0.35), width: 1.5) : null,
        ),
        child: Column(
          children: [
            // TOP BANNER — sadece 1. mekan için
            if (isTop)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Row(children: [
                  Text(_sortType == FindItSortType.communityScore ? '👑' : '📍', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(_sortType == FindItSortType.communityScore ? 'Topluluk\'un En Çok Önerdiği' : 'Sana En Yakın Mekan', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  if (r.ratingsTotal > 0 && _sortType == FindItSortType.communityScore)
                    Text(r.reviewLabel, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                  if (_sortType == FindItSortType.distance)
                    Text(r.distanceLabel, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                ]),
              ),

            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                // Thumbnail
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 58, height: 58,
                        color: AppTheme.accentGlow,
                        child: photoUrl != null
                            ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.place_rounded, color: AppTheme.accent, size: 26))
                            : const Icon(Icons.place_rounded, color: AppTheme.accent, size: 26),
                      ),
                    ),
                    // Rank badge
                    Positioned(
                      top: -2, left: -2,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppTheme.accent : index == 1 ? const Color(0xFF64748B) : index == 2 ? const Color(0xFFB45309) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text('${index + 1}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800,
                                  color: index < 3 ? Colors.white : AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(r.address,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textTertiary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),

                    // Badges row
                    Wrap(spacing: 5, runSpacing: 4, children: [
                      // Distance
                      _badge(Icons.near_me_rounded, r.distanceLabel, gradient: true),

                      // Rating + review count
                      if (r.rating > 0)
                        _badge(Icons.star_rounded, '${r.rating.toStringAsFixed(1)}  ·  ${r.reviewLabel}',
                            color: AppTheme.accentAmber),

                      // Open/closed
                      _badge(
                        r.isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        r.isOpen ? 'Açık' : 'Kapalı',
                        color: r.isOpen ? AppTheme.success : AppTheme.error,
                      ),
                    ]),
                  ]),
                ),

                const SizedBox(width: 8),
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.navigation_rounded, color: AppTheme.accent, size: 18),
                ),
              ]),
            ),
          ],
        ),
      ),
    )
      .animate()
      .slideY(begin: 0.15, duration: 300.ms, delay: Duration(milliseconds: index * 50))
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  Widget _badge(IconData icon, String text, {bool gradient = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: gradient ? AppTheme.accentGradient : null,
        color: gradient ? null : (color ?? AppTheme.textTertiary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: gradient ? Colors.white : (color ?? AppTheme.textSecondary)),
        const SizedBox(width: 3),
        Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600,
            color: gradient ? Colors.white : (color ?? AppTheme.textSecondary))),
      ]),
    );
  }
}
