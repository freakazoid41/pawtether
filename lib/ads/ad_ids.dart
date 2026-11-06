import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob IDs — Android is REAL production, iOS still Google TEST ids.
/// Swap iOS when its keys exist.
class AdIds {
  AdIds._();

  static String get appId => Platform.isIOS
      // Test app ID (iOS).
      ? 'ca-app-pub-3940256099942544~1458002511'
      // REAL app ID (Android).
      : 'ca-app-pub-1088997129209291~3718255248';

  /// Debug builds use Google's TEST banner so development never
  /// generates invalid traffic. Release builds use the REAL unit —
  /// shipping test ads to users earns zero revenue and risks policy flags.
  static String get homeBanner => kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-1088997129209291/4899027866';
}
