/// Compry — Premium Typography System
/// Font: Roboto — bundled with the app for reliable offline startup.
/// Scale follows Material Design 3 Type Scale
library;

import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static TextStyle _roboto({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0,
    double height = 1.4,
  }) =>
      TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        fontFeatures: const [
          FontFeature.enable('kern'),
          FontFeature.enable('liga'),
        ],
      );

  // ─── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      );

  static TextStyle get displayMedium => _roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
      );

  // ─── Headline ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => _roboto(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
      );

  static TextStyle get headlineMedium => _roboto(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.29,
      );

  static TextStyle get headlineSmall => _roboto(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.27,
      );

  // ─── Title ─────────────────────────────────────────────────────────────────
  static TextStyle get titleLarge => _roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.28,
      );

  static TextStyle get titleMedium => _roboto(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get titleSmall => _roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      );

  // ─── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get bodySmall => _roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.33,
      );

  // ─── Label ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => _roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get labelMedium => _roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.33,
      );

  static TextStyle get labelSmall => _roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      );
}
