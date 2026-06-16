import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int? _selectedFeedback; // 1 = 👍, -1 = 👎
  final TextEditingController _noteController = TextEditingController();
  bool _showNote = false;
  bool _submitted = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedFeedback == null) return;
    final provider = context.read<AppProvider>();
    await provider.saveFeedback(
      _selectedFeedback!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    setState(() => _submitted = true);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/home');
  }

  void _skip() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final place = provider.currentRecommendation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _submitted ? _buildSuccessState() : _buildFeedbackForm(place?.name ?? 'Bu mekan'),
        ),
      ),
    );
  }

  Widget _buildFeedbackForm(String placeName) {
    return Column(
      children: [
        const Spacer(),

        // Emoji indicator
        const Icon(Icons.maps_home_work_rounded, size: 64, color: AppTheme.accent)
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'Nasıldı?',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        const SizedBox(height: 8),

        Text(
          placeName,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

        const Spacer(),

        // Feedback Buttons
        Row(
          children: [
            Expanded(
              child: _buildFeedbackButton(
                feedback: 1,
                icon: Icons.thumb_up_rounded,
                label: 'Güzeldi',
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeedbackButton(
                feedback: -1,
                icon: Icons.thumb_down_rounded,
                label: 'Beğenmedim',
                color: AppTheme.error,
              ),
            ),
          ],
        ).animate().slideY(begin: 0.3, duration: 400.ms, delay: 300.ms).fadeIn(duration: 400.ms, delay: 300.ms),

        // Optional Note
        if (_selectedFeedback != null && _showNote) ...[
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            style: GoogleFonts.outfit(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Bir not ekle (opsiyonel)...',
              hintStyle: GoogleFonts.outfit(color: AppTheme.textTertiary),
            ),
            maxLength: 100,
          ).animate().fadeIn(duration: 300.ms),
        ] else if (_selectedFeedback != null && !_showNote) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _showNote = true),
            child: Text(
              '+ Not ekle',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textTertiary,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.textTertiary,
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Submit
        if (_selectedFeedback != null)
          GestureDetector(
            onTap: _submitFeedback,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Gönder',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _skip,
          child: Text(
            'Atla',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required int feedback,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final selected = _selectedFeedback == feedback;

    return GestureDetector(
      onTap: () => setState(() => _selectedFeedback = feedback),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: selected ? color : AppTheme.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: AppTheme.success)
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'Teşekkürler!',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sistem seni öğreniyor',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.psychology_rounded, size: 18, color: AppTheme.accent),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
      ],
    );
  }
}
