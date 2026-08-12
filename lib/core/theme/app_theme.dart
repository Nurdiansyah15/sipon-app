import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────
// APP COLOR TOKENS — mirrors sipon-ui's Nuxt UI config (primary: teal,
// neutral: slate), see app.config.ts in sipon-ui.
// ─────────────────────────────────────────────────────────────────────────
class AppColors {
  // Brand (teal)
  static const primary = Color(0xFF0D9488); // teal-600
  static const primaryLight = Color(0xFF14B8A6); // teal-500
  static const primaryDark = Color(0xFF0F766E); // teal-700
  static const primaryDarker = Color(0xFF115E59); // teal-800

  /// Solid background used by the auth (login/register) screens in
  /// sipon-ui — a slightly darker teal than the `primary` token.
  static const authBackground = Color(0xFF0B857A);

  // Logo mark dots (see AppLogoMark)
  static const logoDotYellow = Color(0xFFFACC15);
  static const logoDotTeal = Color(0xFF14B8A6);
  static const logoDotGreen = Color(0xFF22C55E);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);

  // Neutrals (slate)
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE5E7EB);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);

  AppColors._();
}

// ─────────────────────────────────────────────────────────────────────────
// TEXT STYLES — system default font, matching sipon-ui (no custom family).
// ─────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  AppTextStyles._();
}

// ─────────────────────────────────────────────────────────────────────────
// APP THEME
// ─────────────────────────────────────────────────────────────────────────
class AppTheme {
  static const _radiusLg = BorderRadius.all(Radius.circular(10)); // rounded-lg
  static const _radiusFull = BorderRadius.all(Radius.circular(999)); // rounded-full

  static final ColorScheme _lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCCFBF1), // teal-100
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: AppColors.primaryDark,
    tertiary: AppColors.primaryDarker,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );

  static ThemeData get lightTheme => _buildTheme(_lightColorScheme);

  AppTheme._();

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: onSurface),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: onSurface),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: onSurface),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: onSurface),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: onSurface),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: onSurface),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: onSurfaceVariant),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: onSurface),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: onSurfaceVariant),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(colorScheme),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _radiusLg,
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: _radiusLg),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: _radiusLg),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: _radiusLg,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radiusLg,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radiusLg,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _radiusLg,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return Colors.transparent;
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _radiusFull),
        side: BorderSide.none,
      ),
    );
  }
}
