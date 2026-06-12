import 'dart:math';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Engaging Turkish notification messages ──────────────────
  static const List<Map<String, String>> _reminders = [
    {'title': 'Bugün ne yapıyoruz? 🔥', 'body': 'Karar vermek mi zor? Farketmez Kanka halleder!'},
    {'title': 'Akşam planın var mı? ⚡', 'body': 'Bir tap\'la yeni bir mekan keşfet, kankalar bekliyor!'},
    {'title': 'Hareket zamanı! 🚀', 'body': 'Aynı yerlerde takılıp kalmayın, yeni mekanlar seni bekliyor.'},
    {'title': 'Kanka, açsınız değil mi? 🍽️', 'body': 'Nereye gideceğinize biz karar verelim!'},
    {'title': 'Yeni keşifler seni bekliyor! 🗺️', 'body': 'Çevrende gizli kalan güzel mekanları keşfet.'},
    {'title': 'Arkadaşlarınla takılma vakti! 👥', 'body': 'Ne yapacaksınız diye düşünme, bırak biz bulalım.'},
    {'title': 'Bu akşam bir şeyler yapalım! 🌙', 'body': 'Kahve mi? Yemek mi? Eğlence mi? Farketmez!'},
    {'title': 'Sevgilinle özel bir akşam 💕', 'body': 'Romantik bir mekan önerisi için Farketmez Kanka\'yı aç!'},
    {'title': 'Aile keyfi zamanı! 👨‍👩‍👧', 'body': 'Aile dostu mekanlar sizi bekliyor!'},
    {'title': 'Çay mı kahve mi? ☕', 'body': 'Farketmez, yakındaki en iyi kafeyi biz seçelim!'},
  ];

  static const List<Map<String, String>> _weekendMessages = [
    {'title': 'Hafta sonu geldi! 🎉', 'body': 'Bu hafta sonu nereye gidiyorsunuz? Farketmez Kanka\'ya sor!'},
    {'title': 'Cumartesi planın ne? 🌟', 'body': 'Yeni yerler keşfetmek için harika bir gün. Hadi bakalım!'},
    {'title': 'Pazar gezisi! ☀️', 'body': 'Çevrendeki mekanları keşfet, hem kültür hem eğlence!'},
  ];

  // ── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    await _scheduleAll();
  }

  // ── Channels ─────────────────────────────────────────────────
  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      'farketmez_reminders',
      'Farketmez Hatırlatmalar',
      channelDescription: 'Günlük mekan ve etkinlik önerileri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF4500),
      playSound: true,
      enableLights: true,
      ledColor: Color(0xFFFF4500),
      ledOnMs: 1000,
      ledOffMs: 500,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── Schedule All ─────────────────────────────────────────────
  Future<void> _scheduleAll() async {
    await _plugin.cancelAll();

    // Her gün 15:00 — öğleden sonra (grup kararı zamanı)
    await _scheduleDaily(id: 1, hour: 15, minute: 0, msg: _reminders[0]);
    // Her gün 19:00 — akşam planı
    await _scheduleDaily(id: 2, hour: 19, minute: 0, msg: _reminders[1]);
    // Her gün 12:00 — öğle vakti
    await _scheduleDaily(id: 3, hour: 12, minute: 0, msg: _reminders[6]);

    // Cuma 18:00 — hafta sonu başlıyor
    await _scheduleWeekly(id: 10, weekday: DateTime.friday, hour: 18, minute: 0, msg: _weekendMessages[0]);
    // Cumartesi 10:00
    await _scheduleWeekly(id: 11, weekday: DateTime.saturday, hour: 10, minute: 0, msg: _weekendMessages[1]);
    // Pazar 11:00
    await _scheduleWeekly(id: 12, weekday: DateTime.sunday, hour: 11, minute: 0, msg: _weekendMessages[2]);
  }

  Future<void> _scheduleDaily({
    required int id, required int hour, required int minute,
    required Map<String, String> msg,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id, msg['title']!, msg['body']!,
        _nextInstanceOf(hour, minute),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to schedule daily notification id: $id', e, stack);
    }
  }

  Future<void> _scheduleWeekly({
    required int id, required int weekday, required int hour, required int minute,
    required Map<String, String> msg,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id, msg['title']!, msg['body']!,
        _nextWeekday(weekday, hour, minute),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to schedule weekly notification id: $id', e, stack);
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (s.isBefore(now)) s = s.add(const Duration(days: 1));
    return s;
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (next.weekday != weekday || next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Test bildirimi gönder (geliştirme için)
  Future<void> sendTestNotification() async {
    if (!_initialized) await init();
    final msg = _reminders[Random().nextInt(_reminders.length)];
    await _plugin.show(99, msg['title'], msg['body'], _details);
  }
}
