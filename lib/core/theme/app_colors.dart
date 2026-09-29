/// Compry — Premium Color Palette
/// Material Design 3 — Refined HSL palette
library;

import 'package:flutter/material.dart';

/// Light theme colors — refined greens + warm neutrals
abstract final class AppColorsLight {
  // Brand — sophisticated forest green
  static const Color primary = Color(0xFF176B3A);
  static const Color primaryVariant = Color(0xFF0D4125);
  static const Color secondary = Color(0xFF287C4A);
  static const Color tertiary = Color(0xFFA85F00);

  // Surface hierarchy (5 levels for depth)
  static const Color background = Color(0xFFF5F7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFE9EEE6);
  static const Color surfaceContainerLow = Color(0xFFFAFBF8);
  static const Color surfaceContainerHigh = Color(0xFFDCE4DA);
  static const Color surfaceVariant = Color(0xFFE4F2E8);

  // Semantic
  static const Color success = Color(0xFF1B7A3C);
  static const Color warning = Color(0xFFE07B00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF1565C0);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF131B14);
  static const Color textSecondary = Color(0xFF4C584E);
  static const Color textTertiary = Color(0xFF626E64);
  static const Color textDisabled = Color(0xFFAEB7AC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Priority colors — more saturated, distinct
  static const Color priorityLow = Color(0xFF059669);
  static const Color priorityMedium = Color(0xFF2563EB);
  static const Color priorityHigh = Color(0xFFD97706);
  static const Color priorityUrgent = Color(0xFFDC2626);

  // Status colors
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusPending = Color(0xFF2563EB);
  static const Color statusInProgress = Color(0xFFD97706);
  static const Color statusFinished = Color(0xFF059669);
  static const Color statusCancelled = Color(0xFFDC2626);

  // Offline
  static const Color offline = Color(0xFFF59E0B);
  static const Color offlineText = Color(0xFF111827);

  // Borders & dividers
  static const Color divider = Color(0xFFCBD4C8);
  static const Color outline = Color(0xFFAEB9AC);
  static const Color outlineVariant = Color(0xFFC5CFC2);

  // Shadows
  static const Color shadow = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
}

/// Dark theme colors — layered surfaces, no pure black
abstract final class AppColorsDark {
  // Brand — vibrant but not neon
  static const Color primary = Color(0xFF4ADE80);
  static const Color primaryVariant = Color(0xFF22C55E);
  static const Color secondary = Color(0xFF34D399);
  static const Color tertiary = Color(0xFF6EE7B7);

  // Surface hierarchy (5 levels — no pure black)
  static const Color background = Color(0xFF101410);
  static const Color surface = Color(0xFF191E19);
  static const Color surfaceContainer = Color(0xFF202620);
  static const Color surfaceContainerLow = Color(0xFF141914);
  static const Color surfaceContainerHigh = Color(0xFF293029);
  static const Color surfaceVariant = Color(0xFF173523);

  // Semantic
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF374151);
  static const Color textOnPrimary = Color(0xFF052E16);

  // Priority colors — slightly more muted in dark
  static const Color priorityLow = Color(0xFF34D399);
  static const Color priorityMedium = Color(0xFF60A5FA);
  static const Color priorityHigh = Color(0xFFFBBF24);
  static const Color priorityUrgent = Color(0xFFF87171);

  // Status colors
  static const Color statusDraft = Color(0xFF9CA3AF);
  static const Color statusPending = Color(0xFF60A5FA);
  static const Color statusInProgress = Color(0xFFFBBF24);
  static const Color statusFinished = Color(0xFF4ADE80);
  static const Color statusCancelled = Color(0xFFF87171);

  // Offline
  static const Color offline = Color(0xFFFBBF24);
  static const Color offlineText = Color(0xFF052E16);

  // Borders & dividers
  static const Color divider = Color(0xFF1F2937);
  static const Color outline = Color(0xFF374151);
  static const Color outlineVariant = Color(0xFF1F2937);

  // Shadows
  static const Color shadow = Color(0x40000000);
  static const Color shadowMedium = Color(0x60000000);
}
