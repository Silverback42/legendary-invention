import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Verwaltet lokale Notifications (woechentlicher Digest).
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'schlicht_weekly_digest';
  static const _channelName = 'Weekly Digest';
  static const _digestNotificationId = 42;

  /// Einmalig beim App-Start aufrufen.
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    // Lokale Zeitzone setzen, damit _nextSunday10am() korrekt rechnet.
    // Fallback auf UTC falls die Geraetezeitzone nicht gefunden wird.
    try {
      final deviceTz = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(deviceTz));
    } on Object {
      // timeZoneName liefert u.U. Abkuerzungen wie 'CET', die tz nicht kennt.
      // In dem Fall versuchen wir den Offset-basierten Ansatz.
      try {
        final offset = DateTime.now().timeZoneOffset;
        final locations = tz.timeZoneDatabase.locations.values.where(
          (tz.Location loc) =>
              loc.currentTimeZone.offset == offset.inMilliseconds,
        );
        if (locations.isNotEmpty) {
          tz.setLocalLocation(locations.first);
        }
      } on Object {
        // Kein Match gefunden — tz.local bleibt auf UTC.
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  /// Notification-Permission anfordern (iOS 10+, Android 13+).
  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }

  /// Woechentlichen Digest planen (Sonntag, 10:00 Uhr).
  static Future<void> scheduleWeeklyDigest({
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        _digestNotificationId,
        title,
        body,
        _nextSunday10am(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule digest: $e');
    }
  }

  /// Geplanten Digest abbrechen.
  static Future<void> cancelWeeklyDigest() async {
    await _plugin.cancel(_digestNotificationId);
  }

  /// Naechsten Sonntag 10:00 Uhr (lokal) berechnen.
  static tz.TZDateTime _nextSunday10am() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);

    // Zum naechsten Sonntag vorruecken
    while (scheduled.weekday != DateTime.sunday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Wenn bereits vorbei, naechste Woche
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }
}
