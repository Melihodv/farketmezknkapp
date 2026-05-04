import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late bool _isVegetarian;
  late bool _likesSpicy;
  late int _budgetIndex;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    _isVegetarian = user?.isVegetarian ?? false;
    _likesSpicy = user?.likesSpicy ?? false;
    final bl = user?.budgetLevel ?? 'fark_etmez';
    _budgetIndex = ['ekonomik', 'orta', 'fark_etmez'].indexOf(bl);
    if (_budgetIndex < 0) _budgetIndex = 2;
  }

  Future<void> _save() async {
    await context.read<AppProvider>().updatePreferences({
      'isVegetarian': _isVegetarian,
      'likesSpicy': _likesSpicy,
      'budgetLevel': ['ekonomik', 'orta', 'fark_etmez'][_budgetIndex],
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.cardBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Tercihler', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            GestureDetector(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.accentShadow),
                child: Text('Kaydet', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // ── Diyet ────────────────────────
          Text('🥗  Diyet', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _toggle(Icons.eco_rounded, 'Vejeteryanım', 'Et içermeyen mekanlar öne çıksın', _isVegetarian, (v) => setState(() => _isVegetarian = v)),
          const SizedBox(height: 8),
          _toggle(Icons.local_fire_department_rounded, 'Acıyı severim', 'Baharatlı mekanlar dahil edilsin', _likesSpicy, (v) => setState(() => _likesSpicy = v)),
          const SizedBox(height: 22),

          // ── Bütçe ─────────────────────────
          Text('💰  Bütçe', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (i) {
              final labels = ['Ekonomik', 'Orta', 'Fark etmez'];
              final icons = [Icons.savings_rounded, Icons.credit_card_rounded, Icons.auto_awesome_rounded];
              final sel = _budgetIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _budgetIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.accentGradient : null,
                      color: sel ? null : AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: sel ? AppTheme.accentShadow : null,
                    ),
                    child: Column(children: [
                      Icon(icons[i], color: sel ? Colors.white : AppTheme.textTertiary, size: 22),
                      const SizedBox(height: 6),
                      Text(labels[i], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textTertiary), textAlign: TextAlign.center),
                    ]),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _toggle(IconData icon, String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: val ? AppTheme.accentGlow : AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: val ? Border.all(color: AppTheme.accent.withValues(alpha: 0.3)) : null,
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: val ? AppTheme.accent : Colors.white, borderRadius: BorderRadius.circular(11), boxShadow: val ? AppTheme.accentShadow : AppTheme.smallShadow),
          child: Icon(icon, color: val ? Colors.white : AppTheme.textTertiary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
        ])),
        Switch(value: val, onChanged: onChanged, activeThumbColor: Colors.white, activeTrackColor: AppTheme.accent, inactiveTrackColor: AppTheme.cardBorder),
      ]),
    );
  }
}
