import 'dart:io';

/// AdMob IDs — Android is REAL production, iOS still Google TEST ids.
/// Swap iOS when its keys exist.
class AdIds {
  AdIds._();

  static String get appId => Platform.isIOS
      // Test app ID (iOS).
      ? 'ca-app-pub-3940256099942544~1458002511'
      // REAL app ID (Android).
      : 'ca-app-pub-1088997129209291~3718255248';

  /// TEST banner until production (real unit gets no fill yet).
  static const String homeBanner = 'ca-app-pub-3940256099942544/6300978111';
}
