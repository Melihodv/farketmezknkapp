import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/constants/app_constants.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});
  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _goingConfirmed = false;
  late String _activitySuggestion;
  late String _activityLabel;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final provider = context.read<AppProvider>();
    final groupId = provider.selectedGroupId;

    switch (groupId) {
      case 'solo':
        _activitySuggestion = AppConstants.soloActivities[
            rng.nextInt(AppConstants.soloActivities.length)];
        _activityLabel = 'Yalnız Keyfi';
        break;
      case 'romantic':
        _activitySuggestion = AppConstants.romanticActivities[
            rng.nextInt(AppConstants.romanticActivities.length)];
        _activityLabel = 'Sevgiliye Özel İpucu';
        break;
      case 'friends':
        _activitySuggestion = AppConstants.friendsActivities[
            rng.nextInt(AppConstants.friendsActivities.length)];
        _activityLabel = 'Arkadaş Aktivitesi';
        break;
      default: // family veya diğerleri
        _activitySuggestion = AppConstants.outdoorActivities[
            rng.nextInt(AppConstants.outdoorActivities.length)];
        _activityLabel = 'Aktivite Önerisi';
    }
  }

  Future<void> _openMaps(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final place = provider.currentRecommendation;
    final distanceInfo = provider.distanceInfo as Map<String, String>?;
    final visitRecord = provider.currentVisitRecord;

    if (place == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: AppTheme.accentGlow, shape: BoxShape.circle),
                  child: const Icon(Icons.search_off_rounded, color: AppTheme.accent, size: 40),
                ),
                const SizedBox(height: 20),
                Text('Mekan Bulunamadı', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('Mesafeyi artır veya farklı kategori dene!', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 28),
                _btn(text: 'Geri Dön', onTap: () => context.pop()),
              ]),
            ),
          ),
        ),
      );
    }

    final catData = AppConstants.categories.firstWhere(
      (c) => c['id'] == place.category,
      orElse: () => AppConstants.categories.first,
    );

    final photoUrl = (place.photoReference?.isNotEmpty == true)
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photo_reference=${place.photoReference}&key=${AppConstants.googleMapsApiKey}'
        : '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              if (place.isSponsored)
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20)),
                  child: Text('⭐ Öne Çıkan', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          httpHeaders: const {},
                          placeholder: (c, u) => _photoPlaceholder(catData),
                          errorWidget: (c, u, e) => _photoPlaceholder(catData),
                        )
                      : _photoPlaceholder(catData),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppTheme.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Prev visit warning
                  if (visitRecord != null && visitRecord.visitCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.history_rounded, color: AppTheme.warning, size: 16),
                        const SizedBox(width: 8),
                        Text('Buraya daha önce gittin (${visitRecord.visitCount} kez)',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.warning, fontWeight: FontWeight.w500)),
                      ]),
                    ).animate().slideY(begin: -0.2, duration: 300.ms).fadeIn(duration: 300.ms),

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_catIcon(place.category), color: AppTheme.accent, size: 13),
                      const SizedBox(width: 5),
                      Text(catData['label'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                    ]),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 10),

                  // Name
                  Text(
                    place.name,
                    style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5, height: 1.1),
                  ).animate().slideX(begin: -0.1, duration: 400.ms, delay: 150.ms).fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 6),

                  // Address
                  Row(children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.textTertiary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text(place.address,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ]).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 16),

                  // Stats chips
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      if (place.rating > 0)
                        _chip(Icons.star_rounded, '${place.rating.toStringAsFixed(1)} (${_fmt(place.userRatingsTotal)})'),
                      if (distanceInfo != null && (distanceInfo['distance']?.isNotEmpty == true))
                        _chip(Icons.directions_walk_rounded, distanceInfo['distance']!),
                      if (distanceInfo != null && (distanceInfo['duration']?.isNotEmpty == true))
                        _chip(Icons.access_time_rounded, distanceInfo['duration']!),
                      if (place.isOpen)
                        _chip(Icons.check_circle_rounded, 'Açık', color: AppTheme.success),
                    ],
                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 300.ms).fadeIn(duration: 400.ms, delay: 300.ms),

                  // Sponsor note
                  if (place.isSponsored && place.sponsoredNote != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.accentGlow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
                      child: Row(children: [
                        const Icon(Icons.campaign_rounded, color: AppTheme.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(place.sponsoredNote!,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.accent))),
                      ]),
                    ),
                  ],

                  // Activity Card — her grup tipinde gösterilir
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.accentShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(_activityLabel,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700,
                                color: Colors.white70, letterSpacing: 0.3)),
                      ]),
                      const SizedBox(height: 8),
                      Text(_activitySuggestion,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600,
                              color: Colors.white, height: 1.4)),
                    ]),
                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 350.ms).fadeIn(duration: 400.ms, delay: 350.ms),

                  const SizedBox(height: 28),

                  // Gidiyoruz Button
                  if (!_goingConfirmed)
                    GestureDetector(
                      onTap: () async {
                        await provider.confirmGoingToPlace();
                        await _openMaps(place.latitude, place.longitude, place.name);
                        if (mounted) setState(() => _goingConfirmed = true);
                        if (mounted) {
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) context.push('/feedback');
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppTheme.accentShadow),
                        child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text('Gidiyoruz!',
                              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ])),
                      ),
                    ).animate().scale(duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut)
                  else
                    Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.4))),
                      child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
                        const SizedBox(width: 10),
                        Text('Google Maps açıldı!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.success)),
                      ])),
                    ),

                  const SizedBox(height: 12),

                  // Tekrar çevir
                  GestureDetector(
                    onTap: () async {
                      setState(() => _goingConfirmed = false);
                      await provider.getAnotherRecommendation();
                    },
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow),
                      child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 18),
                        const SizedBox(width: 8),
                        Text('Bir daha çevir',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ])),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(Map<String, dynamic> catData) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.heroGradient),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_catIcon(catData['id'] as String), color: Colors.white.withValues(alpha: 0.8), size: 80),
          const SizedBox(height: 8),
          Text(catData['label'] as String,
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white60)),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color != null ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: color == null ? AppTheme.smallShadow : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color ?? AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: color ?? AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _btn({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.accentShadow),
        child: Text(text, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
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

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}B' : n.toString();
}
