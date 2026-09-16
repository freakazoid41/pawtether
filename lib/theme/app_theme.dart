import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF8A4C); // warm tangerine
  static const Color primaryDark = Color(0xFFE06A28);
  static const Color secondary = Color(0xFF6EC6A1); // sage green
  static const Color accent = Color(0xFFFFB457); // amber honey
  static const Color honey = Color(0xFFFFC46B);
  static const Color blush = Color(0xFFFFD9CE); // soft peach
  static const Color meadow = Color(0xFFDFF3E4); // soft mint
  static const Color cream = Color(0xFFFFF6EC);
  static const Color bg = Color(0xFFFFFAF3);
  static const Color ink = Color(0xFF3A2E28); // warm cocoa
  static const Color muted = Color(0xFF9A8A7D);
  static const Color danger = Color(0xFFE05B4D);
  static const Color card = Colors.white;
  static const Color pawTint = Color(0xFFFFE8D6); // paw-print tint

  // ---- Animal-friendly species palette (soft but distinct) ----
  static const Color dog = Color(0xFFFF8A4C); // tangerine runner
  static const Color cat = Color(0xFF9B7EDE); // lavender queen
  static const Color budgie = Color(0xFF4AA8E0); // sky chatterbox
  static const Color parrot = Color(0xFF58B368); // leafy toddler
  static const Color rabbit = Color(0xFFD96C8A); // rose nibbler
  static const Color fish = Color(0xFF0E7C86); // deep-sea glub
  static const Color other = Color(0xFF6EC6A1); // sage mystery

  // Soft wash backgrounds per species (for headers, chips, banners).
  static const Color dogWash = Color(0xFFFFE8D6);
  static const Color catWash = Color(0xFFE9E1FA);
  static const Color budgieWash = Color(0xFFDCEFFB);
  static const Color parrotWash = Color(0xFFDDF2E2);
  static const Color rabbitWash = Color(0xFFF9DEE6);
  static const Color fishWash = Color(0xFFD5EEF0);
  static const Color otherWash = Color(0xFFDFF3E4);

  /// Main tint for a species index (0=dog,1=cat,2=budgie,3=parrot,else).
  static Color speciesTint(String speciesName) {
    switch (speciesName) {
      case 'dog':
        return dog;
      case 'cat':
        return cat;
      case 'budgie':
        return budgie;
      case 'parrot':
        return parrot;
      case 'rabbit':
        return rabbit;
      case 'fish':
        return fish;
      default:
        return other;
    }
  }

  /// Pale wash for a species — safe as a card/banner background.
  static Color speciesWash(String speciesName) {
    switch (speciesName) {
      case 'dog':
        return dogWash;
      case 'cat':
        return catWash;
      case 'budgie':
        return budgieWash;
      case 'parrot':
        return parrotWash;
      case 'rabbit':
        return rabbitWash;
      case 'fish':
        return fishWash;
      default:
        return otherWash;
    }
  }
}

class AppTheme {
  static ThemeData light() => _base(Brightness.light).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.card,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          foregroundColor: AppColors.ink,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cream,
          labelStyle:
              TextStyle(color: AppColors.ink.withValues(alpha: 0.7)),
          hintStyle: const TextStyle(color: AppColors.muted),
          prefixIconColor: AppColors.primaryDark,
          suffixStyle:
              TextStyle(color: AppColors.ink.withValues(alpha: 0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: AppColors.pawTint, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.cream,
          elevation: 0,
          indicatorColor: AppColors.primary.withValues(alpha: 0.22),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                  color: AppColors.primaryDark, size: 24);
            }
            return const IconThemeData(color: AppColors.muted, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.ink);
            }
            return const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.muted);
          }),
        ),
        chipTheme: ChipThemeData(
          shape: const StadiumBorder(),
          side: BorderSide.none,
          selectedColor: AppColors.primary.withValues(alpha: 0.22),
          backgroundColor: AppColors.cream,
          labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.ink.withValues(alpha: 0.8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      );

  static ThemeData _base(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: b,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: null,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
      ),
      // Animal-friendly: extra-round cards (28), chunky touch targets.
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        margin: EdgeInsets.zero,
      ),
      // NOTE: input + nav + chip themes live in light() above.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      // Cozy pill buttons everywhere.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedColor: AppColors.primary.withValues(alpha: 0.22),
        backgroundColor: AppColors.cream,
        labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink.withValues(alpha: 0.8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      // NOTE: NavigationBar colors live in light() above.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : null),
      ),
    );
  }
}