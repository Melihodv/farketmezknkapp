import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text('Gizlilik Politikası',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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
              const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text('Gizliliğiniz\nBizim İçin Önemli',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
              const SizedBox(height: 6),
              Text('Son Güncelleme: 02 Mayıs 2026',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
            ]),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),

          const SizedBox(height: 20),

          _intro(
            'Ottovate ("biz", "bize" veya "bizim"), Farketmez Kanka adlı mobil uygulamayı geliştirmiş ve sunmaktadır. Bu Gizlilik Politikası, Uygulamamızı kullandığınızda kişisel verilerinizin nasıl toplandığını, kullanıldığını ve paylaşıldığını açıklamaktadır.\n\nUygulamamızı indirerek veya kullanarak bu politikadaki şartları kabul etmiş olursunuz.',
          ),

          const SizedBox(height: 16),

          _section(
            number: '1',
            title: 'Toplanan Bilgiler ve Kullanım Amaçları',
            icon: Icons.data_usage_rounded,
            items: [
              _PolicyItem(
                icon: Icons.location_on_rounded,
                title: 'Konum Bilgileri',
                body:
                    'Uygulamamız, size en uygun mekanları önermek, mesafe hesaplamaları yapmak ve harita hizmetlerini sunabilmek amacıyla cihazınızın konum servislerine (GPS ve ağ tabanlı konum) erişim sağlar. Konum verileriniz anlık olarak işlenir ve sunucularımızda kalıcı olarak depolanmaz. Harita ve konum işlevleri için Google Maps API kullanılmaktadır.',
              ),
              _PolicyItem(
                icon: Icons.phone_android_rounded,
                title: 'Kullanım ve Cihaz Verileri',
                body:
                    'Uygulamanın performansını artırmak ve hataları gidermek amacıyla anonimleştirilmiş cihaz bilgileri (işletim sistemi sürümü, cihaz modeli, uygulama içi gezinme hareketleri, kilitlenme raporları) toplanabilir.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '2',
            title: 'Üçüncü Taraf Hizmet Sağlayıcılar',
            icon: Icons.hub_rounded,
            items: [
              _PolicyItem(
                icon: Icons.android_rounded,
                title: 'Google Play Services',
                body: 'Uygulama güvenliği ve temel Android servisleri için kullanılmaktadır.',
              ),
              _PolicyItem(
                icon: Icons.map_rounded,
                title: 'Google Maps Platform',
                body: 'Mekan arama, harita gösterimi ve mesafe hesaplama işlemleri için kullanılmaktadır.',
              ),
              _PolicyItem(
                icon: Icons.analytics_rounded,
                title: 'Firebase Analytics & Crashlytics',
                body: 'Kullanıcı etkileşimlerini analiz etme ve çökme raporları için kullanılmaktadır.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '3',
            title: 'Veri Güvenliği',
            icon: Icons.lock_rounded,
            items: [
              _PolicyItem(
                icon: Icons.security_rounded,
                title: 'Güvenlik Önlemleri',
                body:
                    'Verilerinizin güvenliğini önemsiyoruz. Topladığımız anonim verileri ve anlık konum bilgilerinizi yetkisiz erişime, değiştirilmeye veya sızdırılmaya karşı korumak için endüstri standartlarında güvenlik önlemleri almaktayız. Ancak, internet üzerinden yapılan hiçbir veri aktarımının %100 güvenli olmadığını hatırlatmak isteriz.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '4',
            title: 'Çocukların Gizliliği',
            icon: Icons.child_care_rounded,
            items: [
              _PolicyItem(
                icon: Icons.family_restroom_rounded,
                title: '13 Yaş Altı Politikası',
                body:
                    'Uygulamamız genel kitleye hitap etmekte olup, bilerek 13 yaşın altındaki çocuklardan kişisel veri toplamamaktadır. 13 yaşın altındaki bir çocuğun bize kişisel bilgilerini sağladığını fark edersek, bu bilgileri derhal sistemlerimizden sileriz.',
              ),
            ],
          ),

          const SizedBox(height: 12),

          _section(
            number: '5',
            title: 'Gizlilik Politikasındaki Değişiklikler',
            icon: Icons.update_rounded,
            items: [
              _PolicyItem(
                icon: Icons.notification_important_rounded,
                title: 'Güncellemeler',
                body:
                    'Bu Gizlilik Politikası\'nı zaman zaman güncelleyebiliriz. Herhangi bir değişiklik yapmamız durumunda, güncellenmiş politikayı bu sayfada yayınlayarak ve "Son Güncelleme Tarihi"ni değiştirerek sizi bilgilendireceğiz.',
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
                Text('6. İletişim',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 12),
              _contactRow(Icons.business_rounded, 'Geliştirici', 'Ottovate'),
              const SizedBox(height: 6),
              _contactRow(Icons.email_rounded, 'E-posta', 'info@ottovate.com.tr'),
              const SizedBox(height: 6),
              _contactRow(Icons.language_rounded, 'Web Sitesi', 'www.ottovate.com.tr'),
            ]),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 24),
          Center(
            child: Text('© 2026 Ottovate. Tüm hakları saklıdır.',
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary)),
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
          style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
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
              child: Text(number, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              Text(item.body,
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ])),
          ]),
        )),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 15, color: AppTheme.accent),
      const SizedBox(width: 8),
      Text('$label: ', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      Text(value, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary)),
    ]);
  }
}

class _PolicyItem {
  final IconData icon;
  final String title;
  final String body;
  const _PolicyItem({required this.icon, required this.title, required this.body});
}
