import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text('Kullanım Koşulları',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.accentShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.gavel_rounded, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text('Hizmet Şartları ve\nKurallarımız',
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
              const SizedBox(height: 6),
              Text('Son Güncelleme: 10 Mayıs 2026',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
            ]),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),

          const SizedBox(height: 20),

          _intro(
            'Lütfen Farketmez Kanka mobil uygulamasını kullanmadan önce bu Kullanım Koşulları\'nı ("Koşullar") dikkatlice okuyunuz. Uygulamaya erişerek veya kullanarak bu koşullara tabi olmayı kabul etmiş olursunuz.',
          ),

          const SizedBox(height: 16),

          _section(
            number: '1',
            title: 'Hizmetin Amacı ve Kullanımı',
            icon: Icons.explore_rounded,
            items: [
              _PolicyItem(
                icon: Icons.check_circle_outline_rounded,
                title: 'Öneri Sistemi',
                body:
                    'Farketmez Kanka, kullanıcılarına bulundukları konuma ve tercihlerine göre mekan önerileri sunan bir rehberlik uygulamasıdır. Sunulan mekanlar ve aktiviteler tamamen tavsiye niteliğindedir.',
              ),
              _PolicyItem(
                icon: Icons.warning_amber_rounded,
                title: 'Doğruluk Garantisi Yoktur',
                body:
                    'Uygulama, mekan verilerini üçüncü taraf API\'ler (Örn: Google Maps) üzerinden sağlar. Mekanların açıklığı, çalışma saatleri veya sunduğu hizmetlerdeki değişikliklerden Ottovate sorumlu tutulamaz. Gitmeden önce ilgili mekanı teyit etmeniz tavsiye edilir.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '2',
            title: 'Hesap Sorumlulukları',
            icon: Icons.person_outline_rounded,
            items: [
              _PolicyItem(
                icon: Icons.shield_rounded,
                title: 'Giriş Yöntemleri',
                body: 'Uygulamayı Misafir modunda veya Google/Apple hesabınızla bağlayarak kullanabilirsiniz. Hesap güvenliğinizi sağlamak sizin sorumluluğunuzdadır.',
              ),
              _PolicyItem(
                icon: Icons.delete_forever_rounded,
                title: 'Hesabın Sonlandırılması',
                body: 'Profil bölümünde bulunan "Hesabımı Sil" butonuyla hesabınızı ve uygulamanın kaydettiği tüm verilerinizi kalıcı olarak silebilirsiniz.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '3',
            title: 'Fikri Mülkiyet Hakları',
            icon: Icons.copyright_rounded,
            items: [
              _PolicyItem(
                icon: Icons.app_shortcut_rounded,
                title: 'Uygulama İçi İçerikler',
                body:
                    'Uygulamanın kodları, tasarımı, logoları, metinleri ve genel konseptinin tüm telif hakları Ottovate\'e aittir. İzinsiz kopyalanması veya ticari amaçlarla kullanılması yasaktır.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Contact card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.contact_mail_rounded, color: AppTheme.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Text('4. İletişim',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 12),
              _contactRow(Icons.business_rounded, 'Geliştirici', 'Ottovate'),
              _contactRow(Icons.email_rounded, 'E-posta', 'info@ottovate.com.tr'),
            ]),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 24),
          Center(
            child: Text('© 2026 Ottovate. Tüm hakları saklıdır.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textTertiary)),
          ),
        ],
      ),
    );
  }

  Widget _intro(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.smallShadow,
      ),
      child: Text(text,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _section({
    required String number,
    required String title,
    required IconData icon,
    required List<_PolicyItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(number, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ),
        ]),
        const SizedBox(height: 14),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(8)),
              child: Icon(item.icon, color: AppTheme.accent, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              Text(item.body,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ])),
          ]),
        )),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 15, color: AppTheme.accent),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textPrimary)),
      ]),
    );
  }
}

class _PolicyItem {
  final IconData icon;
  final String title;
  final String body;
  const _PolicyItem({required this.icon, required this.title, required this.body});
}
