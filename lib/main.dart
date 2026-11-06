import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/splash_gate.dart';
import 'services/notification_service.dart';
import 'storage/app_database.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't block first frame on edge-to-edge setup.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  await EasyLocalization.ensureInitialized();

  // ---- Critical path only: open storage, build provider, show UI. ----
  // Everything heavy (ads, date symbols, timezone DB, notification
  // scheduling) used to be awaited here and held the splash for seconds.
  // Cold-start check-ins must be instant, so we runApp first and warm
  // the rest in the background right after the first frame.
  // English date symbols up front (~50ms): 'en' is the fallback locale,
  // so month names never flash untranslated on first paint. The rest
  // warm up in the background below.
  try {
    await initializeDateFormatting('en');
  } catch (e) {
    debugPrint('date symbols en failed: $e');
  }
  final db = AppDatabase();
  await db.init();
  final provider = AppProvider(db)..loadAll();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('ru'),
        Locale('hi'),
        Locale('es'),
        Locale('de'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: PawTetherApp(provider: provider),
    ),
  );

  // ---- Background warm-up, never blocks boot. ----
  // Ads init (network on some devices).
  unawaited(Future(() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('MobileAds init failed: $e');
    }
  }));
  // Local month/day names for DateFormats used across the app.
  unawaited(Future(() async {
    for (final loc in ['tr', 'ru', 'hi', 'es', 'de']) {
      try {
        await initializeDateFormatting(loc);
      } catch (e) {
        debugPrint('date symbols $loc failed: $e');
      }
    }
  }));
  // Notifications: timezone DB load + permission prompt + scheduling.
  // This was the biggest stall (tz database parse on low-end devices).
  // Deferred to after the first frame so the home screen paints first.
  unawaited(Future(() async {
    try {
      await NotificationService.instance.init();
      if ((db.getObject('notify_enabled') as bool?) ?? true) {
        await provider.refreshNotifications();
      }
    } catch (e) {
      debugPrint('Notifications init failed: $e');
    }
  }));
}

class PawTetherApp extends StatelessWidget {
  final AppProvider provider;

  const PawTetherApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Subscribe to EasyLocalization here so the shell rebuilds on locale
    // change. NOTE: no Consumer<AppProvider> above MaterialApp — every
    // notifyListeners (each checkbox/log/delete) used to rebuild the ENTIRE
    // app tree. Locale rebuilds come from EasyLocalization + ValueKey below.
    final locale = context.locale;
    final delegates = context.localizationDelegates;
    final supported = context.supportedLocales;
    // Route every intl DateFormat through the active app locale.
    Intl.defaultLocale = locale.languageCode;
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        // Remount the whole subtree on locale change: .tr() reads
        // translations globally (no inherited subscription) and const
        // home/routes would otherwise keep stale strings.
        key: ValueKey(locale),
        title: 'app_title'.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        localizationsDelegates: delegates,
        supportedLocales: supported,
        locale: locale,
        home: const SplashGate(),
      ),
    );
  }
}