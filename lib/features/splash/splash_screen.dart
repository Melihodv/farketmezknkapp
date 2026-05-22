import 'dart:math' as math;
import 'dart:io' show Platform;
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showAuth = false;
  bool _isLoading = false;

  late final AnimationController _orbController;
  late final AnimationController _particleController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showAuth = true);
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final user = await context.read<AppProvider>().signInWithGoogle();
    if (user != null && mounted) {
      context.go('/home');
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Giriş başarısız. Tekrar dene.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    final user = await context.read<AppProvider>().signInWithApple();
    if (user != null && mounted) {
      context.go('/home');
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Apple girişi başarısız. Tekrar dene.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
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
      body: Stack(
        children: [
          // ── Animated background ──────────────────────────────
          _buildAnimatedBackground(),

          // ── Floating particles ───────────────────────────────
          _buildParticles(),

          // ── Content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const Spacer(flex: 3),
                if (_showAuth) _buildAuthSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // ANIMATED BACKGROUND
  // ────────────────────────────────────────────────────────────
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final t = _orbController.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D0520), Color(0xFF1A0A3E), Color(0xFF0F1A3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Orb 1 — violet
              Positioned(
                top: -80 + t * 60,
                left: -60 + t * 40,
                child: _buildOrb(
                  size: 320,
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                  blur: 80,
                ),
              ),
              // Orb 2 — pink
              Positioned(
                top: 180 + t * 40,
                right: -80 + t * 30,
                child: _buildOrb(
                  size: 260,
                  color: const Color(0xFFEC4899).withValues(alpha: 0.25),
                  blur: 70,
                ),
              ),
              // Orb 3 — deep blue
              Positioned(
                bottom: -60 - t * 30,
                left: 30 + t * 20,
                child: _buildOrb(
                  size: 280,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                  blur: 90,
                ),
              ),
              // Orb 4 — rose (small accent)
              Positioned(
                top: 300 - t * 50,
                left: -40 + t * 60,
                child: _buildOrb(
                  size: 160,
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.20),
                  blur: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrb({required double size, required Color color, required double blur}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: blur, spreadRadius: blur / 2)],
        color: color,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // FLOATING PARTICLES
  // ────────────────────────────────────────────────────────────
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(_particleController.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // LOGO SECTION
  // ────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        // Main icon with glass effect
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = 1.0 + _pulseController.value * 0.04;
            return Transform.scale(
              scale: pulse,
              child: child,
            );
          },
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.6),
                  blurRadius: 50,
                  spreadRadius: 8,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.5),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.3, 0.3),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 400.ms),

        const SizedBox(height: 32),

        // App name
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE0D7FF), Color(0xFFFAD0F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Farketmez',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2.0,
              height: 1.0,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideY(begin: 0.4, duration: 600.ms, delay: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 6),

        // Tagline with decorative lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLine(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'K A N K A',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA78BFA),
                  letterSpacing: 5,
                ),
              ),
            ),
            _buildLine(),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

        const SizedBox(height: 14),

        Text(
          'Ne yapalım? Farketmez kanka.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.2,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

        const SizedBox(height: 28),

        // Feature pills
        _buildFeaturePills()
            .animate()
            .fadeIn(duration: 500.ms, delay: 750.ms)
            .slideY(begin: 0.3, duration: 500.ms, delay: 750.ms),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      width: 32,
      height: 1.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFFA78BFA), Colors.transparent],
        ),
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
    );
  }

  Widget _buildFeaturePills() {
    final pills = [
      ('📍', 'Konum bazlı'),
      ('⚡', 'Anında öneri'),
      ('🧠', 'Akıllı filtre'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pills.map((p) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.$1, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                p.$2,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────
  // AUTH SECTION
  // ────────────────────────────────────────────────────────────
  Widget _buildAuthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Google Sign In
          _buildGoogleBtn(),
          
          const SizedBox(height: 12),
          if (Platform.isIOS) ...[
            _buildAppleBtn(),
            const SizedBox(height: 12),
          ],

          // Divider
          Row(
            children: [
              Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.10))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'ya da',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.10))),
            ],
          ),
          const SizedBox(height: 12),

          // Guest
          _buildGuestBtn(),

          if (_isLoading) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: const Color(0xFFA78BFA),
                strokeWidth: 2.5,
              ),
            ),
          ],

          const SizedBox(height: 22),
          Text(
            'Devam ederek Gizlilik Politikamızı kabul etmiş olursunuz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.3),
              height: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOut)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildGoogleBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _signInWithGoogle,
      child: AnimatedOpacity(
        opacity: _isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEA4335).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFEA4335),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Google ile Giriş Yap',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1033),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _signInWithApple,
      child: AnimatedOpacity(
        opacity: _isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apple, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Apple ile Giriş Yap',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _continueAsGuest,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Center(
          child: Text(
            'Misafir olarak devam et',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// PARTICLE PAINTER
// ────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _random = math.Random(42);

  // Pre-generated particles
  static final List<_Particle> _particles = List.generate(28, (i) {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 1.2 + _random.nextDouble() * 2.5,
      speed: 0.12 + _random.nextDouble() * 0.18,
      opacity: 0.15 + _random.nextDouble() * 0.45,
      phase: _random.nextDouble(),
    );
  });

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final phase = (progress + p.phase) % 1.0;
      final x = p.x * size.width + math.sin(phase * 2 * math.pi * 0.7) * 18;
      final y = (p.y - phase * p.speed) % 1.0;
      final screenY = y * size.height;

      final alpha = (math.sin(phase * math.pi) * p.opacity).clamp(0.0, 1.0);

      // Alternate colors: violet or rose
      final isViolet = _particles.indexOf(p) % 3 != 0;
      paint.color = (isViolet
              ? const Color(0xFFA78BFA)
              : const Color(0xFFEC4899))
          .withValues(alpha: alpha);

      canvas.drawCircle(Offset(x, screenY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, size, speed, opacity, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}
