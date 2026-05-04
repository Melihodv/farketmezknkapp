import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/user_model.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                          const SizedBox(height: 16),
                          _buildRecentOrHint(context),
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
    );
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
                Text(_getGreeting(), style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textTertiary)),
                const SizedBox(height: 1),
                Text('Ne yapalım?', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.8)),
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
                Text(_shortAddr(provider.currentAddress), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, shape: BoxShape.circle, boxShadow: AppTheme.accentShadow),
              child: Center(child: Text(_initials(provider.currentUser), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
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
              Text('Kategori', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.6)),
              GestureDetector(
                onTap: () => _openFilter(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.accentShadow),
                  child: Row(children: [
                    const Icon(Icons.tune_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('Tercihler', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
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
                    color: sel ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: sel ? AppTheme.accentShadow : AppTheme.cardShadow,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_catIcon(cat['id']), color: sel ? Colors.white : AppTheme.textTertiary, size: 24),
                    const SizedBox(height: 6),
                    Text(cat['label'], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary), textAlign: TextAlign.center),
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
              Text('Kimlerle çıkıyorsun?', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textTertiary)),
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
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textTertiary),
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
              Text('Ne kadar uzağa?', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textTertiary)),
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
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? AppTheme.accentGradient : null,
                        color: sel ? null : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: sel ? AppTheme.accentShadow : null,
                      ),
                      child: Center(child: Text(AppConstants.radiusLabels[i],
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textTertiary))),
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
  Widget _buildRecentOrHint(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.recentVisits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.accentShadow),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Keşfe hazır mısın?', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text('Seçimlerini yap, FARKETMEZ\'e bas!', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textTertiary)),
            ])),
          ]),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Son Ziyaretler', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.4)),
            GestureDetector(
              onTap: () => context.push('/memory'),
              child: Text('Tümü →', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
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
                  Text(v.placeName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${v.visitCount}x ziyaret', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
                ])),
                if (v.positiveCount > 0) Text('👍 ${v.positiveCount}', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Yakında uygun mekan bulunamadı, mesafeyi artır!', style: GoogleFonts.outfit(color: Colors.white)),
              ));
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 62,
          decoration: BoxDecoration(
            gradient: loading ? null : AppTheme.accentGradient,
            color: loading ? Colors.white : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: loading ? AppTheme.smallShadow : AppTheme.accentShadow,
          ),
          child: Center(
            child: loading
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Aranıyor...', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ])
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text('FARKETMEZ', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.5)),
                  ]),
          ),
        ),
      ),
    );
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => const FilterBottomSheet());
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
