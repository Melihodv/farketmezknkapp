import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalDiscoveries = 0;
  int _positiveCount = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final provider = context.read<AppProvider>();
    await provider.loadAllVisits();
    final visits = provider.allVisits;
    setState(() {
      _totalDiscoveries = visits.length;
      _positiveCount = visits.fold(0, (sum, v) => sum + v.positiveCount);
      _statsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text('Profil', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [

          // ─── Profile Card ───────────────────────────────────
          _buildProfileCard(user).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),

          const SizedBox(height: 20),

          // ─── Stats Grid ──────────────────────────────────────
          _buildStatsSection().animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 20),

          // ─── App Settings ────────────────────────────────────
          _buildSectionHeader('Uygulama'),
          const SizedBox(height: 10),
          _buildSettingItem(Icons.map_rounded, 'Hafızam', 'Gittiğin mekanlar', onTap: () => context.push('/memory')),
          const SizedBox(height: 8),
          _buildSettingItem(Icons.notifications_rounded, 'Bildirimler', 'Hatırlatmalar ve güncellemeler'),
          const SizedBox(height: 8),
          _buildSettingItem(
            provider.isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            'Uygulama Sesleri',
            'Küçük efektler',
            trailing: Switch(
              value: provider.isSoundEnabled,
              onChanged: (_) => provider.toggleSound(),
              activeThumbColor: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingItem(Icons.info_outline_rounded, 'Hakkında', 'Farketmez Kanka v1.0.0'),

          const SizedBox(height: 20),

          // ─── Account ─────────────────────────────────────────
          _buildSectionHeader('Hesap'),
          const SizedBox(height: 10),
          _buildSettingItem(Icons.logout_rounded, 'Çıkış Yap', 'Hesabından çık',
            onTap: () async {
              final router = GoRouter.of(context);
              await provider.signOut();
              if (mounted) router.go('/');
            },
          ),
          const SizedBox(height: 8),
          if (!(user?.isGuest ?? true))
            _buildSettingItem(Icons.delete_forever_rounded, 'Hesabımı Sil', 'Tüm verilerini kalıcı olarak sil',
              danger: true,
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Emin misin?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    content: Text('Hesabın ve tüm geçmiş ziyaret verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.', style: GoogleFonts.outfit()),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('İptal', style: GoogleFonts.outfit(color: AppTheme.textSecondary))),
                      TextButton(
                        onPressed: () async {
                          final router = GoRouter.of(context);
                          Navigator.of(ctx).pop();
                          await provider.deleteAccount();
                          if (mounted) router.go('/');
                        },
                        child: Text('Hesabı Sil', style: GoogleFonts.outfit(color: AppTheme.error, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
            ),

          // ─── Legal ───────────────────────────────────────────
          _buildSectionHeader('Yasal'),
          const SizedBox(height: 10),
          _buildSettingItem(Icons.shield_rounded, 'Gizlilik Politikası', 'Verileriniz nasıl korunur?',
              onTap: () => context.push('/privacy')),
          const SizedBox(height: 8),
          _buildSettingItem(Icons.gavel_rounded, 'Kullanım Koşulları', 'Uygulama şartları ve koşullar',
              onTap: () => context.push('/terms')),

          const SizedBox(height: 32),

          Center(
            child: Column(children: [
              Text('Farketmez Kanka v1.0.0',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary)),
              const SizedBox(height: 4),
              Text('© 2026 Ottovate. Tüm hakları saklıdır.',
                  style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(user) {
    final displayName = user?.displayName ?? 'Misafir';
    final email = user?.email ?? (user?.isGuest == true ? 'Misafir Hesabı' : '');
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final isGuest = user?.isGuest ?? true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, shape: BoxShape.circle),
            child: Center(child: Text(initials, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(email, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isGuest ? AppTheme.card : AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isGuest ? 'Misafir Modu' : 'Google Hesabı',
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: isGuest ? AppTheme.textTertiary : AppTheme.accent),
              ),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final level = _getLevel(_totalDiscoveries);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('İstatistikler', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 0.4)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(20)),
              child: Text(level, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
            ),
          ]),
          const SizedBox(height: 16),
          _statsLoaded
              ? Row(
                  children: [
                    _buildStatBox(Icons.explore_rounded, '$_totalDiscoveries', 'Keşif'),
                    const SizedBox(width: 10),
                    _buildStatBox(Icons.thumb_up_rounded, '$_positiveCount', 'Beğeni'),
                    const SizedBox(width: 10),
                    _buildStatBox(Icons.local_fire_department_rounded, '${_totalDiscoveries > 0 ? ((_positiveCount / (_totalDiscoveries > 0 ? _totalDiscoveries : 1)) * 100).round() : 0}%', 'Başarı'),
                  ],
                )
              : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2))),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textTertiary)),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 0.5));
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {VoidCallback? onTap, bool danger = false, bool accent = false, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? AppTheme.error.withValues(alpha: 0.08) : accent ? AppTheme.accentGlow : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: danger ? AppTheme.error.withValues(alpha: 0.25) : accent ? AppTheme.accent.withValues(alpha: 0.3) : AppTheme.cardBorder),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: danger ? AppTheme.error.withValues(alpha: 0.12) : accent ? AppTheme.accentGlow : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: danger ? AppTheme.error : accent ? AppTheme.accent : AppTheme.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: danger ? AppTheme.error : accent ? AppTheme.accent : AppTheme.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
          ])),
          if (trailing != null) trailing
          else if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: danger ? AppTheme.error.withValues(alpha: 0.5) : AppTheme.textTertiary, size: 20),
        ]),
      ),
    );
  }

  String _getLevel(int discoveries) {
    if (discoveries >= 50) return '🏆 Efsane';
    if (discoveries >= 20) return '🧭 Kaşif';
    if (discoveries >= 10) return '🔍 Meraklı';
    if (discoveries >= 5) return '✨ Başlangıç';
    return '🌱 Yeni';
  }
}
