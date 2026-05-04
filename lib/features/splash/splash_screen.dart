import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showAuth = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showAuth = true);
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final user = await context.read<AppProvider>().signInWithGoogle();
    if (user != null && mounted) context.go('/home');
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);
    final user = await context.read<AppProvider>().signInAsGuest();
    if (user != null && mounted) context.go('/home');
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const Spacer(flex: 3),
              if (_showAuth) _buildAuthSection(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16), spreadRadius: 4)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.9), size: 62),
              const Positioned(
                top: 28, left: 43,
                child: Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
              ),
            ],
          ),
        )
            .animate()
            .scale(begin: const Offset(0.4, 0.4), end: const Offset(1.0, 1.0), duration: 700.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 400.ms),

        const SizedBox(height: 28),

        Text(
          'Farketmez',
          style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1.5),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.3, duration: 500.ms, delay: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 2,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'KANKA',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent, letterSpacing: 4),
              ),
            ),
            Container(
              width: 28, height: 2,
              decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(1)),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

        const SizedBox(height: 12),

        Text(
          'Ne yapalım? Farketmez kanka.',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
        ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildAuthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Google Sign In
          _buildBtn(
            onTap: _isLoading ? null : _signInWithGoogle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Center(child: Text('G', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFEA4335)))),
                ),
                const SizedBox(width: 12),
                Text('Google ile Giriş Yap', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
            gradient: AppTheme.accentGradient,
          ),
          const SizedBox(height: 12),

          // Guest
          _buildBtn(
            onTap: _isLoading ? null : _continueAsGuest,
            child: Text('Misafir olarak devam et', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
            gradient: null,
          ),

          if (_isLoading) ...[
            const SizedBox(height: 20),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2.5)),
          ],

          const SizedBox(height: 20),
          Text(
            'Devam ederek Gizlilik Politikamızı kabul etmiş olursunuz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary, height: 1.5),
          ),
        ],
      ).animate().slideY(begin: 0.4, duration: 500.ms, curve: Curves.easeOut).fadeIn(duration: 500.ms),
    );
  }

  Widget _buildBtn({required Widget child, required VoidCallback? onTap, LinearGradient? gradient}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? Colors.white : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: gradient != null ? AppTheme.accentShadow : AppTheme.smallShadow,
        ),
        child: Center(child: child),
      ),
    );
  }
}
