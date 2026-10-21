import 'package:flutter/material.dart';

/// Shared semantic palette: leaf, sunshine, coconut flesh and charcoal.
abstract final class KopraPalette {
  static const leaf = Color(0xFF24634B);
  static const leafDark = Color(0xFF163F32);
  static const sunshine = Color(0xFFF1CB58);
  static const canvas = Color(0xFFF5F7F3);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF223B32);
  static const muted = Color(0xFF697B72);
  static const line = Color(0xFFDDE5DF);
  static const leafTint = Color(0xFFE5EFE7);
  static const amber = Color(0xFF976700);
  static const amberTint = Color(0xFFFFF3CE);
  static const danger = Color(0xFFB44238);
  static const dangerTint = Color(0xFFFCEAE5);
  static const shell = Color(0xFF87614C);
  static const flesh = Color(0xFFFFF8E9);
  static const scanBackground = Color(0xFF101C17);
  static const scanScrim = Color(0xAA101C17);
  static const scanHighlight = Color(0xFFA8DB91);
}

const Color kopraGreen = KopraPalette.leaf;

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: KopraPalette.leaf,
        brightness: Brightness.light,
      ).copyWith(
        primary: KopraPalette.leaf,
        onPrimary: KopraPalette.paper,
        primaryContainer: KopraPalette.leafTint,
        onPrimaryContainer: KopraPalette.leafDark,
        secondary: KopraPalette.amber,
        onSecondary: KopraPalette.paper,
        secondaryContainer: KopraPalette.amberTint,
        onSecondaryContainer: KopraPalette.ink,
        surface: KopraPalette.paper,
        onSurface: KopraPalette.ink,
        onSurfaceVariant: KopraPalette.muted,
        outline: KopraPalette.muted,
        outlineVariant: KopraPalette.line,
        error: KopraPalette.danger,
        errorContainer: KopraPalette.dangerTint,
        onErrorContainer: KopraPalette.danger,
      );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  return base.copyWith(
    scaffoldBackgroundColor: KopraPalette.canvas,
    textTheme: base.textTheme
        .copyWith(
          headlineLarge: const TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: KopraPalette.ink,
          ),
          headlineMedium: const TextStyle(
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: KopraPalette.ink,
          ),
          titleLarge: const TextStyle(
            fontSize: 23,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: KopraPalette.ink,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: KopraPalette.ink,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: KopraPalette.ink,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: KopraPalette.ink,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: KopraPalette.muted,
          ),
        )
        .apply(letterSpacingDelta: 0),
    appBarTheme: const AppBarTheme(
      backgroundColor: KopraPalette.canvas,
      foregroundColor: KopraPalette.ink,
      surfaceTintColor: KopraPalette.canvas,
      centerTitle: false,
      elevation: 0,
      toolbarHeight: 72,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: KopraPalette.ink,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: KopraPalette.paper,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: KopraPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: KopraPalette.leaf, width: 2),
      ),
      prefixIconColor: KopraPalette.muted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: shape,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: shape,
        side: const BorderSide(color: KopraPalette.line),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: KopraPalette.paper,
      indicatorColor: KopraPalette.leafTint,
      height: 76,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? KopraPalette.leaf
              : KopraPalette.muted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: KopraPalette.line, space: 24),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: KopraPalette.ink,
      contentTextStyle: TextStyle(
        color: KopraPalette.paper,
        fontSize: 14,
        height: 1.35,
      ),
      shape: shape,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: KopraPalette.leaf,
      linearTrackColor: KopraPalette.leafTint,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: KopraPalette.leaf,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}

Color gradeColor(String grade) => switch (grade) {
  'Well-Dried' => KopraPalette.leaf,
  'Moderately Dried' => KopraPalette.amber,
  _ => KopraPalette.danger,
};

IconData gradeIcon(String grade) => switch (grade) {
  'Well-Dried' => Icons.check_circle_outline_rounded,
  'Moderately Dried' => Icons.wb_sunny_outlined,
  _ => Icons.water_drop_outlined,
};
