import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/user_model.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showIntro = false;
  static const String _prefIntroKey = 'home_intro_shown';

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_prefIntroKey) ?? false;
    if (!shown && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _showIntro = true);
    }
  }

  Future<void> _dismissIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIntroKey, true);
    if (mounted) setState(() => _showIntro = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
            child: Stack(
              children: [
                Positioned(
                  top: -60, right: -60,
                  child: Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildCategorySection(context),
                              const SizedBox(height: 16),
                              _buildGroupCard(context),
                              const SizedBox(height: 12),
                              _buildRadiusCard(context),
                              const SizedBox(height: 14),
                              _buildFindItBanner(context),
                              const SizedBox(height: 16),
                              _buildRouletteBanner(context),
                              const SizedBox(height: 16),
                              _buildRecentVisits(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar(context)),
              ],
            ),
          ),
          // ── İlk Açılış Intro Overlay ──────────────────────
          if (_showIntro) _buildIntroOverlay(),
        ],
      ),
    );
  }

  // ── Intro Overlay ──────────────────────────────────────────
  Widget _buildIntroOverlay() {
    final steps = [
      {'icon': Icons.grid_view_rounded, 'title': 'Kategori Seç', 'desc': 'Yemek, kahve, dışarı... ne istersen seç'},
      {'icon': Icons.people_alt_rounded, 'title': 'Kiminle?', 'desc': 'Yalnız, sevgili, arkadaşlar ya da aile ile'},
      {'icon': Icons.near_me_rounded, 'title': 'Mesafeyi Ayarla', 'desc': '500m\'den 5km\'ye kadar ne kadar uzağa gideceksin?'},
      {'icon': Icons.bolt_rounded, 'title': 'FARKETMEZ\'e Bas!', 'desc': 'Karar zormu? Biz verelim — yakınındaki en iyi mekan'},
      {'icon': Icons.manage_search_rounded, 'title': 'Nereden Bulurum?', 'desc': 'Aklında belirli bir yer mi var? Onu da buluruz'},
      {'icon': Icons.history_rounded, 'title': 'Son Ziyaretler', 'desc': 'Gittiğin yerleri burada görebilir, haritadan takip edebilirsin'},
    ];

    return GestureDetector(
      onTap: _dismissIntro,
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlık
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text('Uygulama Rehberi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
                Text('Nasıl kullanılır?',
                    style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)
                ).animate().slideY(begin: -0.2, duration: 400.ms, delay: 100.ms).fadeIn(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 6),
                Text('Her şey bu ekrandan başlıyor', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white60)
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 24),

                // Adımlar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.6,
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: steps.length,
                  itemBuilder: (_, i) {
                    final s = steps[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(s['icon'] as IconData, color: AppTheme.accentLight, size: 20),
                        const SizedBox(height: 6),
                        Text(s['title'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(s['desc'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white54, height: 1.3), maxLines: 2),
                      ]),
                    ).animate().scale(duration: 350.ms, delay: Duration(milliseconds: 200 + i * 60), curve: Curves.easeOutBack);
                  },
                ),

                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _dismissIntro,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppTheme.accentShadow,
                    ),
                    child: Text('Anladım, başlayalım! 🚀', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textTertiary)),
                const SizedBox(height: 1),
                Text('Ne yapalım?', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.8)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => provider.refreshLocation(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.smallShadow),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on_rounded, color: AppTheme.accent, size: 13),
                const SizedBox(width: 4),
                Text(_shortAddr(provider.currentAddress), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, shape: BoxShape.circle, boxShadow: AppTheme.accentShadow),
              child: Center(child: Text(_initials(provider.currentUser), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Categories ──────────────────────────────────────────
  Widget _buildCategorySection(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kategori', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.6)),
              GestureDetector(
                onTap: () => _openFilter(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.accentShadow),
                  child: Row(children: [
                    const Icon(Icons.tune_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('Tercihler', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, i) {
              final cat = AppConstants.categories[i];
              final sel = provider.selectedCategoryIndex == i;
              return GestureDetector(
                onTap: () => provider.setCategoryIndex(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  width: 78,
                  decoration: BoxDecoration(
                    gradient: sel ? AppTheme.accentGradient : null,
                    color: sel ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: sel ? AppTheme.accentShadow : AppTheme.cardShadow,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_catIcon(cat['id']), color: sel ? Colors.white : AppTheme.textTertiary, size: 24),
                    const SizedBox(height: 6),
                    Text(cat['label'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary), textAlign: TextAlign.center),
                  ]),
                ),
              ).animate().slideX(begin: 0.3, duration: 300.ms, delay: Duration(milliseconds: i * 50)).fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 50));
            },
          ),
        ),
      ],
    );
  }

  // ── Group Card ──────────────────────────────────────────
  Widget _buildGroupCard(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.people_alt_rounded, color: AppTheme.accent, size: 13),
              const SizedBox(width: 4),
              Text('Kimlerle çıkıyorsun?', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textTertiary)),
            ]),
            const SizedBox(height: 12),
            Row(
              children: List.generate(AppConstants.groupTypes.length, (i) {
                final g = AppConstants.groupTypes[i];
                final sel = provider.selectedGroupIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setGroupIndex(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? AppTheme.accentGradient : null,
                        color: sel ? null : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: sel ? AppTheme.accentShadow : null,
                      ),
                      child: Column(children: [
                        Icon(_groupIcon(g['id'] as String), color: sel ? Colors.white : AppTheme.textTertiary, size: 20),
                        const SizedBox(height: 4),
                        Text(g['label'] as String,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textTertiary),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.15, duration: 400.ms, delay: 200.ms).fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ── Radius Card ──────────────────────────────────────────
  Widget _buildRadiusCard(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.radar_rounded, color: AppTheme.accent, size: 13),
              const SizedBox(width: 4),
              Text('Ne kadar uzağa?', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textTertiary)),
            ]),
            const SizedBox(height: 12),
            Row(
              children: List.generate(AppConstants.radiusOptions.length, (i) {
                final sel = provider.selectedRadiusIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setRadiusIndex(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: i < AppConstants.radiusOptions.length - 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? AppTheme.accentGradient : null,
                        color: sel ? null : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: sel ? AppTheme.accentShadow : null,
                      ),
                      child: Center(child: Text(AppConstants.radiusLabels[i],
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textTertiary))),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.15, duration: 400.ms, delay: 250.ms).fadeIn(duration: 400.ms, delay: 250.ms);
  }

  // ── Recent / Hint ──────────────────────────────────────
  // ── Recent Visits (hint kaldırıldı) ─────────────────────
  Widget _buildRecentVisits(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.recentVisits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Son Ziyaretler', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.4)),
            GestureDetector(
              onTap: () => context.push('/memory'),
              child: Text('Tümü →', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 10),
          ...provider.recentVisits.map((v) {
            final cat = AppConstants.categories.firstWhere((c) => c['id'] == v.placeCategory, orElse: () => AppConstants.categories.first);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(10)),
                  child: Icon(_catIcon(cat['id']), color: AppTheme.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.placeName, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${v.visitCount}x ziyaret', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textTertiary)),
                ])),
                if (v.positiveCount > 0) Text('👍 ${v.positiveCount}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textTertiary)),
              ]),
            );
          }),
        ],
      ),
    );
  }


  // ── Bottom Bar ──────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loading = provider.recommendationState == AppState.loading;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          AppTheme.background.withValues(alpha: 0),
          AppTheme.background,
          AppTheme.background,
        ]),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: GestureDetector(
        onTap: loading ? null : () async {
          final result = await provider.getRecommendation();
          if (context.mounted) {
            if (result != null) {
              context.push('/recommendation');
            } else {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_off_rounded, color: AppTheme.warning, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text('Yakında Mekan Yok',
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Seçtiğin mesafede uygun mekan bulunamadı.\nMesafeyi artır veya farklı kategori dene!',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.accentShadow,
                          ),
                          child: Center(child: Text('Tamam',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 62,
          decoration: BoxDecoration(
            gradient: loading ? null : AppTheme.accentGradient,
            color: loading ? AppTheme.surfaceElevated : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: loading ? AppTheme.smallShadow : AppTheme.accentShadow,
          ),
          child: Center(
            child: loading
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Aranıyor...', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ])
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text('FARKETMEZ', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.5)),
                  ]),
          ),
        ),
      ),
    );
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => const FilterBottomSheet());
  }

  // ── FindIt Banner ─────────────────────────────────
  Widget _buildFindItBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/findit'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.accentShadow,
                ),
                child: const Icon(Icons.manage_search_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nereden Bulurum?',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text('Bulamadığın her şeyi bul.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.accentShadow,
                ),
                child: Text('Ara',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.15, duration: 400.ms, delay: 280.ms).fadeIn(duration: 400.ms, delay: 280.ms);
  }

  // ── Roulette Banner ───────────────────────────────
  Widget _buildRouletteBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/roulette'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.accentShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.casino_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kararsız mı kaldın?',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text('Kendi çarkını oluştur ve çevir!',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.smallShadow,
                ),
                child: Text('Çevir',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.15, duration: 400.ms, delay: 320.ms).fadeIn(duration: 400.ms, delay: 320.ms);
  }

  IconData _catIcon(String id) {
    switch (id) {
      case 'food':          return Icons.restaurant_rounded;
      case 'coffee':        return Icons.local_cafe_rounded;
      case 'dessert':       return Icons.cake_rounded;
      case 'entertainment': return Icons.sports_esports_rounded;
      case 'outdoor':       return Icons.park_rounded;
      case 'culture':       return Icons.account_balance_rounded;
      default:              return Icons.place_rounded;
    }
  }

  IconData _groupIcon(String id) {
    switch (id) {
      case 'solo':     return Icons.person_rounded;
      case 'romantic': return Icons.favorite_rounded;
      case 'friends':  return Icons.group_rounded;
      case 'family':   return Icons.family_restroom_rounded;
      default:         return Icons.people_rounded;
    }
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın ☀️';
    if (h < 18) return 'İyi günler 👋';
    return 'İyi akşamlar 🌙';
  }

  String _shortAddr(String addr) {
    final s = addr.split(',').first.trim();
    return s.length > 12 ? '${s.substring(0, 12)}…' : s;
  }

  String _initials(UserModel? u) {
    if (u == null || u.displayName == null) return '?';
    final p = u.displayName!.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p[0].isNotEmpty ? p[0][0].toUpperCase() : '?';
  }
}
