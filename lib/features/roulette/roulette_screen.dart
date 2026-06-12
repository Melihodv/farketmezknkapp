import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/audio_service.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<String> _options = [
    'Sinema',
    'Kahve',
    'Sahil',
  ];

  final List<Color> _colors = [
    const Color(0xFF7C3AED), // Violet
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF10B981), // Mint
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF43F5E), // Rose
  ];

  double _currentAngle = 0;
  bool _isSpinning = false;
  
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _options.isEmpty) return;

    setState(() => _isSpinning = true);

    final randomSpins = 5 + math.Random().nextInt(5);
    final randomAngle = math.Random().nextDouble() * 2 * math.pi;
    final targetAngle = _currentAngle + (randomSpins * 2 * math.pi) + randomAngle;

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
    );

    _controller.forward(from: 0).then((_) {
      _currentAngle = targetAngle % (2 * math.pi);
      _showResult();
      setState(() => _isSpinning = false);
    });
  }

  void _showResult() {
    AudioService().playSuccess();
    
    final totalSweep = 2 * math.pi;
    final singleSweep = totalSweep / _options.length;
    
    // CustomPainter starts 0 degrees at 3 o'clock. Top pointer is at -pi/2 (or 3pi/2).
    final offset = (3 * math.pi / 2) - _currentAngle;
    final positiveOffset = (offset % totalSweep + totalSweep) % totalSweep;
    final winningIndex = (positiveOffset / singleSweep).floor();
    
    final winner = _options[winningIndex];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Result',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(color: AppTheme.accent.withValues(alpha: 0.4), blurRadius: 50, spreadRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.accentShadow,
                    ),
                    child: const Center(child: Icon(Icons.celebration_rounded, size: 45, color: AppTheme.accent)),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text('Çarkın Kararı:', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textTertiary)),
                  const SizedBox(height: 12),
                  Text(
                    winner,
                    style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -1),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: AppTheme.accentShadow,
                      ),
                      child: Center(
                        child: Text('Mükemmel Seçim!', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  void _addOption() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_options.contains(text)) {
      AudioService().playPop();
      setState(() {
        _options.add(text);
        _textController.clear();
      });
    }
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      AudioService().playPop();
      setState(() {
        _options.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('En az 2 seçenek olmalı!'), backgroundColor: AppTheme.warning),
      );
    }
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildWheel(),
                      const SizedBox(height: 40),
                      _buildOptionsList(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildSpinButton(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kararsız mı kaldın?', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textTertiary)),
                Text('Çarkı Çevir', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              ],
            ),
          ),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.accentShadow),
            child: const Icon(Icons.casino_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildWheel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow behind the wheel removed to prevent gray square artifacts on some devices
        // The spinning wheel
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: _WheelPainter(_options, _colors),
                ),
              ),
            );
          },
        ),
        // Center cap
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppTheme.accent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5),
            ],
            border: Border.all(color: AppTheme.accent, width: 6),
          ),
          child: Center(
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Pointer at the top
        Positioned(
          top: -15,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.accentShadow,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Center(
              child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 500.ms);
  }

  Widget _buildOptionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seçenekleri Düzenle', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _options.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colors[idx % _colors.length].withValues(alpha: 0.1),
                    border: Border.all(color: _colors[idx % _colors.length].withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: _colors[idx % _colors.length])),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeOption(idx),
                        child: Icon(Icons.close_rounded, size: 16, color: _colors[idx % _colors.length].withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Yeni seçenek ekle...',
                        hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textTertiary),
                      ),
                      onSubmitted: (_) => _addOption(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addOption,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.accentShadow,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 150.ms).fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildSpinButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
      child: GestureDetector(
        onTap: _spin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 62,
          decoration: BoxDecoration(
            gradient: _isSpinning ? null : AppTheme.accentGradient,
            color: _isSpinning ? AppTheme.surfaceElevated : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: _isSpinning ? AppTheme.smallShadow : AppTheme.accentShadow,
          ),
          child: Center(
            child: _isSpinning
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Çevriliyor...', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ])
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.casino_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text('ÇARKI ÇEVİR', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
                  ]),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 250.ms).fadeIn(duration: 400.ms, delay: 250.ms);
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;

  _WheelPainter(this.items, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sweepAngle = 2 * math.pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Draw text
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(i * sweepAngle + sweepAngle / 2);
      
      final text = items[i].length > 15 ? '${items[i].substring(0, 13)}...' : items[i];

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width / 2.5);
      canvas.translate(size.width / 4, -textPainter.height / 2); 
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
    
    // Draw outer border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
