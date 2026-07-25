/// Compry — Premium Color Palette
/// Material Design 3 — Refined HSL palette
library;

import 'package:flutter/material.dart';

/// Light theme colors — refined greens + warm neutrals
abstract final class AppColorsLight {
  // Brand — sophisticated forest green
  static const Color primary = Color(0xFF1B7A3C);
  static const Color primaryVariant = Color(0xFF145E2E);
  static const Color secondary = Color(0xFF2D9E5F);
  static const Color tertiary = Color(0xFF0A5C28);

  // Surface hierarchy (5 levels for depth)
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F2F5);
  static const Color surfaceContainerLow = Color(0xFFF8FAFB);
  static const Color surfaceContainerHigh = Color(0xFFE8EAED);
  static const Color surfaceVariant = Color(0xFFE3EBE5);

  // Semantic
  static const Color success = Color(0xFF1B7A3C);
  static const Color warning = Color(0xFFE07B00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF1565C0);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
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
  static const Color divider = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFFD1D5DB);
  static const Color outlineVariant = Color(0xFFE5E7EB);

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
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF16181F);
  static const Color surfaceContainer = Color(0xFF1C1F28);
  static const Color surfaceContainerLow = Color(0xFF13151C);
  static const Color surfaceContainerHigh = Color(0xFF252830);
  static const Color surfaceVariant = Color(0xFF1E2430);

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
