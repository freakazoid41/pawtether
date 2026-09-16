import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';
import '../utils/i18n_helpers.dart';

/// Local push, intentionally LAST phase per idea.md §9.
/// - Daily 9am (device-local): "Did you feed X?"
/// - Every enabled reminder fires at its next occurrence.
/// - Immediate nudge for overdue medical reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool get isReady => _ready;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'pawtether_daily',
          'Daily care',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      );

  tz.TZDateTime _next9am() {
    // Device-local 9am: the tz database parks tz.local on UTC, so convert
    // the local instant explicitly instead of trusting tz.local.
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 9);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return _zoned(next);
  }

  /// Converts a device-local wall time to a scheduler instant.
  tz.TZDateTime _zoned(DateTime local) => tz.TZDateTime.from(local, tz.UTC);

  /// Schedules one daily 9am nudge per pet. Call on boot + pet add/delete.
  Future<void> scheduleDailyFeedNudges(List<Pet> pets) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    var id = 100;
    for (final pet in pets) {
      await _plugin.zonedSchedule(
        id: id++,
        title: 'notif_feed_title'.tr(namedArgs: {'name': pet.name}),
        body: 'notif_feed_body'.tr(),
        scheduledDate: _next9am(),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'feed:${pet.id}',
      );
    }
  }

  /// Fires every enabled reminder at its next occurrence (one-shot each;
  /// refreshed on every boot and every reminder mutation).
  Future<void> scheduleReminderOccurrences(
    List<Reminder> reminders,
    Map<String, String> petNames,
  ) async {
    if (!_ready) return;
    final upcoming = <({Reminder r, DateTime at})>[];
    for (final r in reminders) {
      if (!r.enabled) continue;
      final at = r.nextOccurrence();
      if (at == null) continue;
      upcoming.add((r: r, at: at));
    }
    upcoming.sort((a, b) => a.at.compareTo(b.at));
    var n = 0;
    for (final e in upcoming.take(50)) {
      final r = e.r;
      await _plugin.zonedSchedule(
        // cancelAll + reschedule on every refresh, so slot ids are safe.
        id: 1000 + (n++),
        title: seedTr(r.title),
        body: '${petNames[r.petId] ?? ''} · ${DateFormat.Hm().format(e.at)}',
        scheduledDate: _zoned(e.at),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'reminder:${r.id}',
      );
    }
  }

  /// Immediate nudge for overdue medical reminders.
  Future<void> scheduleOverdueNudge(List<Reminder> reminders) async {
    if (!_ready) return;
    final overdue = reminders.where((r) {
      if (!r.enabled || !r.isOverdue) return false;
      return r.type == ReminderType.vaccine ||
          r.type == ReminderType.medication ||
          r.type == ReminderType.vet;
    }).toList();
    if (overdue.isEmpty) return;
    await _plugin.show(
      id: 999,
      title: overdue.length == 1
          ? 'notif_overdue_one'.tr()
          : 'notif_overdue_many'
              .tr(namedArgs: {'count': '${overdue.length}'}),
      body: overdue.take(3).map((r) => seedTr(r.title)).join(' · '),
      notificationDetails: _details(),
      payload: 'overdue',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
