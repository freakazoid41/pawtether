import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  await EasyLocalization.ensureInitialized();
  // Ads are best-effort: never block boot.
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('MobileAds init failed: $e');
  }
  // Local month/day names for tr/ru/hi DateFormats used across the app.
  for (final loc in ['tr', 'ru', 'hi']) {
    try {
      await initializeDateFormatting(loc);
    } catch (_) {}
  }
  final db = AppDatabase();
  await db.init();
  final provider = AppProvider(db)..loadAll();

  // Notifications are best-effort: never block boot.
  try {
    await NotificationService.instance.init();
    if ((db.getObject('notify_enabled') as bool?) ?? true) {
      await provider.refreshNotifications();
    }
  } catch (e) {
    debugPrint('Notifications init failed: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('ru'),
        Locale('hi'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: PawTetherApp(provider: provider),
    ),
  );
}

class PawTetherApp extends StatelessWidget {
  final AppProvider provider;

  const PawTetherApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Subscribe to EasyLocalization here (above ChangeNotifierProvider/
    // Consumer) so the whole app shell rebuilds on locale change.
    // Without this, EasyLocalization returns the same child instance and
    // Consumer never re-runs, leaving MaterialApp + .tr() strings stale.
    final locale = context.locale;
    final delegates = context.localizationDelegates;
    final supported = context.supportedLocales;
    // Route every intl DateFormat through the active app locale.
    Intl.defaultLocale = locale.toString();
    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}