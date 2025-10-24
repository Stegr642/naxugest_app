import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================
/// TOKENS COULEURS (ta palette)
/// =============================
class AppColors {
  // Palette fournie
  static const Color brandPrimary = Color(0xFF023859); // RVB 2,56,89
  static const Color brandSecondary = Color(0xFF025E73); // RVB 2,94,115
  static const Color brandCyan = Color(0xFF0BD9D9); // RVB 11,217,217
  static const Color neutral98 = Color(0xFFF2F2F2); // RVB 242,242,242
  static const Color accentOrange = Color(0xFFF28F38); // RVB 242,143,56

  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF0B1216);

  // Dérivés doux (containers / surfaces teintées)
  static const Color primaryContainer = Color(0xFF0B5C8F);
  static const Color secondaryContainer = Color(0xFF0B7F96);
  static const Color tertiaryContainer = Color(0xFFEFEFEF);
  static const Color cyanContainer = Color(0xFFCFF8F8);

  // Surfaces dark
  static const Color darkBg = Color(0xFF0F171D);
  static const Color darkSurface = Color(0xFF121F27);
  static const Color darkSurfaceVariant = Color(0xFF17303A);
}

/// =============================
/// TYPOGRAPHIE (Google Fonts)
/// =============================
TextTheme _textTheme(ColorScheme scheme) {
  final base = GoogleFonts.interTextTheme();
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
    displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700),
    headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.3),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.35),
    bodySmall: base.bodySmall?.copyWith(height: 1.35),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w600),
  );
}

/// =============================
/// COLOR SCHEMES M3
/// =============================
ColorScheme _lightScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.brandPrimary,
  onPrimary: AppColors.white,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.white,
  secondary: AppColors.brandSecondary,
  onSecondary: AppColors.white,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.white,
  tertiary: AppColors.accentOrange,
  onTertiary: AppColors.nearBlack,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.nearBlack,
  error: Color(0xFFB3261E),
  onError: AppColors.white,
  errorContainer: Color(0xFFF9DEDC),
  onErrorContainer: Color(0xFF410E0B),
  surface: AppColors.white,
  onSurface: AppColors.nearBlack,
  surfaceContainerHighest: Color(0xFFE5EEF2),
  onSurfaceVariant: Color(0xFF3B4A54),
  outline: Color(0xFF8CA0AC),
  outlineVariant: Color(0xFFD3DFE6),
  inverseSurface: AppColors.nearBlack,
  onInverseSurface: AppColors.neutral98,
  inversePrimary: AppColors.brandCyan,
  scrim: Colors.black54,
);

ColorScheme _darkScheme = const ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.brandCyan,
  onPrimary: AppColors.nearBlack,
  primaryContainer: AppColors.brandSecondary,
  onPrimaryContainer: AppColors.white,
  secondary: AppColors.brandPrimary,
  onSecondary: AppColors.white,
  secondaryContainer: AppColors.darkSurfaceVariant,
  onSecondaryContainer: AppColors.neutral98,
  tertiary: AppColors.accentOrange,
  onTertiary: AppColors.nearBlack,
  tertiaryContainer: Color(0xFF3B2A1F),
  onTertiaryContainer: AppColors.neutral98,
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DEDC),
  surface: AppColors.darkSurface,
  onSurface: AppColors.neutral98,
  surfaceContainerHighest: AppColors.darkSurfaceVariant,
  onSurfaceVariant: Color(0xFFC7D5DD),
  outline: Color(0xFF7D909A),
  outlineVariant: Color(0xFF2A3B45),
  inverseSurface: AppColors.neutral98,
  onInverseSurface: AppColors.nearBlack,
  inversePrimary: AppColors.brandCyan,
  scrim: Colors.black54,
);

/// =============================
/// THÈME LIGHT
/// =============================
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightScheme,
  textTheme: _textTheme(_lightScheme),
  scaffoldBackgroundColor: _lightScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightScheme.surface,
    foregroundColor: _lightScheme.onSurface,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: _textTheme(_lightScheme).titleLarge?.copyWith(
          color: _lightScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
  ),
  cardTheme: CardThemeData(
    color: _lightScheme.surface,
    elevation: 1,
    margin: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.neutral98,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightScheme.primary, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightScheme.primary,
      foregroundColor: _lightScheme.onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _lightScheme.secondary,
      foregroundColor: _lightScheme.onSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _lightScheme.primary,
      side: BorderSide(color: _lightScheme.outline),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentOrange,
    foregroundColor: AppColors.nearBlack,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.cyanContainer,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    labelStyle: _textTheme(_lightScheme).labelLarge?.copyWith(
          color: _lightScheme.onPrimaryContainer,
        ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _lightScheme.surface,
    indicatorColor: _lightScheme.primary.withOpacity(0.12),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(color: _lightScheme.onSurface),
    ),
    labelTextStyle: WidgetStatePropertyAll(
      _textTheme(_lightScheme).labelMedium!,
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: _lightScheme.surface,
    selectedTileColor: _lightScheme.primary.withOpacity(0.08),
    iconColor: _lightScheme.onSurfaceVariant,
  ),
  dividerTheme: DividerThemeData(
    color: _lightScheme.outlineVariant,
    thickness: 1,
    space: 24,
  ),
  dataTableTheme: DataTableThemeData(
    headingTextStyle: _textTheme(_lightScheme).labelLarge?.copyWith(
          color: _lightScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
    headingRowColor: WidgetStatePropertyAll(AppColors.neutral98),
    dataTextStyle: _textTheme(_lightScheme).bodyMedium,
    dividerThickness: 0.6,
  ),
);

/// =============================
/// THÈME DARK
/// =============================
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkScheme,
  textTheme: _textTheme(_darkScheme),
  scaffoldBackgroundColor: _darkScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkScheme.surface,
    foregroundColor: _darkScheme.onSurface,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: _textTheme(_darkScheme).titleLarge?.copyWith(
          color: _darkScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
  ),
  cardTheme: CardThemeData(
    color: _darkScheme.surface,
    elevation: 0,
    margin: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkScheme.primary, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkScheme.primary,
      foregroundColor: _darkScheme.onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _darkScheme.secondary,
      foregroundColor: _darkScheme.onSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _darkScheme.primary,
      side: BorderSide(color: _darkScheme.outline),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentOrange,
    foregroundColor: AppColors.nearBlack,
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.brandPrimary.withOpacity(0.25),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    labelStyle: _textTheme(_darkScheme).labelLarge?.copyWith(
          color: _darkScheme.onSurface,
        ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _darkScheme.surface,
    indicatorColor: _darkScheme.primary.withOpacity(0.14),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(color: _darkScheme.onSurface),
    ),
    labelTextStyle: WidgetStatePropertyAll(
      _textTheme(_darkScheme).labelMedium!,
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: _darkScheme.surface,
    selectedTileColor: _darkScheme.primary.withOpacity(0.12),
    iconColor: _darkScheme.onSurfaceVariant,
  ),
  dividerTheme: DividerThemeData(
    color: _darkScheme.outlineVariant,
    thickness: 1,
    space: 24,
  ),
  dataTableTheme: DataTableThemeData(
    headingTextStyle: _textTheme(_darkScheme).labelLarge?.copyWith(
          color: _darkScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
    headingRowColor:
        WidgetStatePropertyAll(_darkScheme.surfaceContainerHighest),
    dataTextStyle: _textTheme(_darkScheme).bodyMedium?.copyWith(
          color: _darkScheme.onSurface,
        ),
    dividerThickness: 0.6,
  ),
);
