import 'package:flutter/material.dart';

// Voyna 브랜드 컬러
const _voynaBlue = Color(0xFF0071E3);
const _voynaPurple = Color(0xFFAF52DE);
const _voynaGold = Color(0xFFFFD700);

final ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: _voynaBlue,
  brightness: Brightness.light,
  secondary: _voynaPurple,
  tertiary: _voynaGold,
);

final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: _voynaBlue,
  brightness: Brightness.dark,
  secondary: _voynaPurple,
  tertiary: _voynaGold,
);

ThemeData _baseTheme(ColorScheme scheme) {
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Pretendard',
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

final ThemeData voynaLightTheme = _baseTheme(_lightScheme);
final ThemeData voynaDarkTheme = _baseTheme(_darkScheme);

// 컬러 직접 노출 (배지 등에 사용)
class VoynaColors {
  static const blue = _voynaBlue;
  static const purple = _voynaPurple;
  static const gold = _voynaGold;
  static const gradeCommon = Color(0xFFFEF3C7);
  static const gradeRare = Color(0xFFDBEAFE);
  static const gradeSpecial = Color(0xFFFCE4EC);
  static const gradePremier = Color(0xFFFFF9C4);
}
