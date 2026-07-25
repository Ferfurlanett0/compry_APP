/// Compry — Premium App Theme
/// Material Design 3 — Light & Dark with 5-level surface hierarchy
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

final class AppTheme {
  const AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: _buildTextTheme(AppColorsLight.textPrimary),
        appBarTheme: _appBarTheme(
          backgroundColor: AppColorsLight.surface,
          foregroundColor: AppColorsLight.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColorsLight.surface,
          ),
        ),
        cardTheme: _cardTheme(AppColorsLight.surface),
        elevatedButtonTheme: _elevatedButtonTheme(_lightColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_lightColorScheme),
        textButtonTheme: _textButtonTheme(_lightColorScheme),
        inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
        checkboxTheme: _checkboxTheme(_lightColorScheme),
        switchTheme: _switchTheme(_lightColorScheme),
        navigationBarTheme: _navigationBarTheme(_lightColorScheme),
        dividerTheme: const DividerThemeData(
          color: AppColorsLight.divider,
          thickness: 1,
          space: 0,
        ),
        scaffoldBackgroundColor: AppColorsLight.background,
        listTileTheme: _listTileTheme(AppColorsLight.textPrimary, _lightColorScheme),
        snackBarTheme: _snackBarTheme(),
        dialogTheme: _dialogTheme(AppColorsLight.surface),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColorsLight.primary,
          linearTrackColor: AppColorsLight.surfaceContainerHigh,
          linearMinHeight: AppDimensions.progressBarHeight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        chipTheme: _chipTheme(_lightColorScheme),
        floatingActionButtonTheme: _fabTheme(_lightColorScheme),
        bottomSheetTheme: _bottomSheetTheme(AppColorsLight.surface),
        iconTheme: const IconThemeData(color: AppColorsLight.textPrimary, size: AppDimensions.iconLG),
        splashColor: AppColorsLight.primary.withValues(alpha: 0.08),
        highlightColor: AppColorsLight.primary.withValues(alpha: 0.05),
      );

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: _buildTextTheme(AppColorsDark.textPrimary),
        appBarTheme: _appBarTheme(
          backgroundColor: AppColorsDark.surface,
          foregroundColor: AppColorsDark.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColorsDark.surface,
          ),
        ),
        cardTheme: _cardTheme(AppColorsDark.surface),
        elevatedButtonTheme: _elevatedButtonTheme(_darkColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_darkColorScheme),
        textButtonTheme: _textButtonTheme(_darkColorScheme),
        inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
        checkboxTheme: _checkboxTheme(_darkColorScheme),
        switchTheme: _switchTheme(_darkColorScheme),
        navigationBarTheme: _navigationBarTheme(_darkColorScheme),
        dividerTheme: const DividerThemeData(
          color: AppColorsDark.divider,
          thickness: 1,
          space: 0,
        ),
        scaffoldBackgroundColor: AppColorsDark.background,
        listTileTheme: _listTileTheme(AppColorsDark.textPrimary, _darkColorScheme),
        snackBarTheme: _snackBarTheme(),
        dialogTheme: _dialogTheme(AppColorsDark.surfaceContainer),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColorsDark.primary,
          linearTrackColor: AppColorsDark.surfaceContainerHigh,
          linearMinHeight: AppDimensions.progressBarHeight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        chipTheme: _chipTheme(_darkColorScheme),
        floatingActionButtonTheme: _fabTheme(_darkColorScheme),
        bottomSheetTheme: _bottomSheetTheme(AppColorsDark.surfaceContainer),
        iconTheme: const IconThemeData(color: AppColorsDark.textPrimary, size: AppDimensions.iconLG),
        splashColor: AppColorsDark.primary.withValues(alpha: 0.12),
        highlightColor: AppColorsDark.primary.withValues(alpha: 0.06),
      );

  // ─── Color Schemes ─────────────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColorsLight.primary,
    onPrimary: AppColorsLight.textOnPrimary,
    primaryContainer: Color(0xFFD1FAE5),
    onPrimaryContainer: Color(0xFF052E16),
    secondary: AppColorsLight.secondary,
    onSecondary: AppColorsLight.textOnPrimary,
    secondaryContainer: Color(0xFFDCFCE7),
    onSecondaryContainer: Color(0xFF052E16),
    tertiary: AppColorsLight.tertiary,
    onTertiary: AppColorsLight.textOnPrimary,
    tertiaryContainer: Color(0xFFA7F3D0),
    onTertiaryContainer: Color(0xFF022C17),
    error: AppColorsLight.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: AppColorsLight.surface,
    onSurface: AppColorsLight.textPrimary,
    surfaceContainerHighest: AppColorsLight.surfaceContainerHigh,
    surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
    surfaceContainer: AppColorsLight.surfaceContainer,
    surfaceContainerLow: AppColorsLight.surfaceContainerLow,
    surfaceContainerLowest: AppColorsLight.background,
    onSurfaceVariant: AppColorsLight.textSecondary,
    outline: AppColorsLight.outline,
    outlineVariant: AppColorsLight.outlineVariant,
    shadow: AppColorsLight.shadow,
    scrim: Color(0x52000000),
    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: AppColorsDark.primary,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.textOnPrimary,
    primaryContainer: Color(0xFF052E16),
    onPrimaryContainer: Color(0xFFD1FAE5),
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.textOnPrimary,
    secondaryContainer: Color(0xFF052E16),
    onSecondaryContainer: Color(0xFFDCFCE7),
    tertiary: AppColorsDark.tertiary,
    onTertiary: AppColorsDark.textOnPrimary,
    tertiaryContainer: Color(0xFF022C17),
    onTertiaryContainer: Color(0xFFA7F3D0),
    error: AppColorsDark.error,
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.textPrimary,
    surfaceContainerHighest: AppColorsDark.surfaceContainerHigh,
    surfaceContainerHigh: AppColorsDark.surfaceContainerHigh,
    surfaceContainer: AppColorsDark.surfaceContainer,
    surfaceContainerLow: AppColorsDark.surfaceContainerLow,
    surfaceContainerLowest: AppColorsDark.background,
    onSurfaceVariant: AppColorsDark.textSecondary,
    outline: AppColorsDark.outline,
    outlineVariant: AppColorsDark.outlineVariant,
    shadow: AppColorsDark.shadow,
    scrim: Color(0x52000000),
    inverseSurface: Color(0xFFF9FAFB),
    onInverseSurface: Color(0xFF1F2937),
    inversePrimary: AppColorsLight.primary,
  );

  // ─── Component Themes ──────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color defaultColor) {
    final base = GoogleFonts.interTextTheme().apply(
      bodyColor: defaultColor,
      displayColor: defaultColor,
    );
    return base.copyWith(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: defaultColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: defaultColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: defaultColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: defaultColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: defaultColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: defaultColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: defaultColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: defaultColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: defaultColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: defaultColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: defaultColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: defaultColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: defaultColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: defaultColor),
    );
  }

  static AppBarTheme _appBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) =>
      AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: systemOverlayStyle,
        surfaceTintColor: Colors.transparent,
      );

  static CardThemeData _cardTheme(Color backgroundColor) => CardThemeData(
        color: backgroundColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return cs.onSurface.withValues(alpha: 0.12);
            }
            return cs.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return cs.onSurface.withValues(alpha: 0.38);
            }
            return cs.onPrimary;
          }),
          minimumSize: const WidgetStatePropertyAll(
            Size(double.infinity, AppDimensions.buttonHeight),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
            ),
          ),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: WidgetStatePropertyAll(
            AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceXS,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.08);
            }
            return null;
          }),
          animationDuration: const Duration(milliseconds: 150),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          ),
          side: BorderSide(color: cs.primary.withValues(alpha: 0.5), width: 1.5),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(88, AppDimensions.buttonHeightSM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        errorStyle: AppTextStyles.labelSmall.copyWith(color: cs.error),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return cs.primary;
          return cs.onSurfaceVariant;
        }),
      );

  static CheckboxThemeData _checkboxTheme(ColorScheme cs) => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(cs.onPrimary),
        side: BorderSide(color: cs.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );

  static SwitchThemeData _switchTheme(ColorScheme cs) => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.onPrimary;
          return cs.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.surfaceContainerHighest;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      );

  static NavigationBarThemeData _navigationBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary, size: AppDimensions.iconLG);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: AppDimensions.iconLG);
        }),
        height: AppDimensions.bottomNavHeight,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      );

  static ListTileThemeData _listTileTheme(Color textColor, ColorScheme cs) =>
      ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceXS,
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: textColor.withValues(alpha: 0.6),
        ),
        minVerticalPadding: AppDimensions.spaceXS,
        minLeadingWidth: AppDimensions.iconLG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      );

  static SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        actionTextColor: const Color(0xFF4ADE80),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceXS,
        ),
      );

  static DialogThemeData _dialogTheme(Color backgroundColor) => DialogThemeData(
        backgroundColor: backgroundColor,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
        surfaceTintColor: Colors.transparent,
      );

  static ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        disabledColor: cs.surfaceContainerHighest,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceXS,
          vertical: AppDimensions.spaceXXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: BorderSide.none,
        ),
        showCheckmark: false,
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      );

  static FloatingActionButtonThemeData _fabTheme(ColorScheme cs) =>
      FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        extendedTextStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
        ),
      );

  static BottomSheetThemeData _bottomSheetTheme(Color backgroundColor) =>
      BottomSheetThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
      );
}
