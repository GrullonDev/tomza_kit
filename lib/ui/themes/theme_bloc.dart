import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tomza_kit/ui/themes/colors.dart';
import 'package:tomza_kit/ui/themes/status_color.dart';

enum ThemeType { blue, orange, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeType _currentThemeType = ThemeType.blue;

  ThemeType get currentThemeType => _currentThemeType;

  void toggleTheme() {
    if (_currentThemeType == ThemeType.blue) {
      _currentThemeType = ThemeType.orange;
    } else if (_currentThemeType == ThemeType.orange) {
      _currentThemeType = ThemeType.dark;
    } else {
      _currentThemeType = ThemeType.blue;
    }
    notifyListeners();
  }

  bool get isDarkMode => _currentThemeType == ThemeType.dark;

  ThemeData get currentTheme {
    switch (_currentThemeType) {
      case ThemeType.blue:
        return lightTheme;
      case ThemeType.orange:
        return orangeTheme;
      case ThemeType.dark:
        return darkTheme;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.light()],

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: TomzaColorsBlue.primary,
        primary: TomzaColorsBlue.primary,
        onPrimary: Colors.white,
        secondary: TomzaColorsBlue.dark,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: TomzaColorsBlue.darkGrey,
        // background: surfaceGrey, // deprecated
        // onBackground: darkGrey, // deprecated
        error: TomzaColorsBlue.errorRed,
        onError: Colors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Colors.white,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: TomzaColorsBlue.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme: white background with elevation, shape, margin for contrast
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ListTile Theme: white tiles with primary color icons, shape and padding
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: TomzaColorsBlue.primary,
        iconColor: TomzaColorsBlue.primary,
        textColor: TomzaColorsBlue.darkGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TomzaColorsBlue.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TomzaColorsBlue.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TomzaColorsBlue.surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColorsBlue.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColorsBlue.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsBlue.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsBlue.errorRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColorsBlue.mediumGrey,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColorsBlue.mediumGrey,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.alexandriaTextTheme().copyWith(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: TomzaColorsBlue.darkGrey,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: TomzaColorsBlue.darkGrey,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TomzaColorsBlue.darkGrey,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColorsBlue.darkGrey,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: TomzaColorsBlue.darkGrey,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: TomzaColorsBlue.darkGrey,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: TomzaColorsBlue.mediumGrey,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColorsBlue.mediumGrey,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: TomzaColorsBlue.mediumGrey,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: TomzaColorsBlue.mediumGrey,
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme: stronger contrast
      dividerTheme: DividerThemeData(
        color: TomzaColorsBlue.mediumGrey.withValues(alpha: 0.5),
        thickness: 1,
        space: 0.5,
      ),
      // DataTable Theme: improved table styling
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(TomzaColorsBlue.surfaceGrey),
        headingTextStyle: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TomzaColorsBlue.darkGrey,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: GoogleFonts.alexandria(
          fontSize: 14,
          color: TomzaColorsBlue.darkGrey,
        ),
        dividerThickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: TomzaColorsBlue.lightGrey,
        selectedColor: TomzaColorsBlue.accent,
        disabledColor: TomzaColorsBlue.mediumGrey.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: TomzaColorsBlue.mediumGrey.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get orangeTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.light()],

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: TomzaColorsOrange.primary,
        primary: TomzaColorsOrange.primary,
        onPrimary: Colors.white,
        secondary: TomzaColorsOrange.dark,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: TomzaColorsOrange.darkGrey,
        error: TomzaColorsOrange.errorRed,
        onError: Colors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Colors.white,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: TomzaColorsOrange.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme: white background with elevation, shape, margin for contrast
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ListTile Theme: white tiles with primary color icons, shape and padding
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: TomzaColorsOrange.primary,
        iconColor: TomzaColorsOrange.primary,
        textColor: TomzaColorsOrange.darkGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TomzaColorsOrange.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TomzaColorsOrange.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TomzaColorsOrange.surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColorsOrange.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColorsOrange.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsOrange.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsOrange.errorRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColorsOrange.mediumGrey,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColorsOrange.mediumGrey,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.alexandriaTextTheme().copyWith(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: TomzaColorsOrange.darkGrey,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: TomzaColorsOrange.darkGrey,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TomzaColorsOrange.darkGrey,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColorsOrange.darkGrey,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: TomzaColorsOrange.darkGrey,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: TomzaColorsOrange.darkGrey,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: TomzaColorsOrange.mediumGrey,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColorsOrange.mediumGrey,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: TomzaColorsOrange.mediumGrey,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: TomzaColorsOrange.mediumGrey,
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme: stronger contrast
      dividerTheme: DividerThemeData(
        color: TomzaColorsOrange.mediumGrey.withValues(alpha: 0.5),
        thickness: 1,
        space: 0.5,
      ),
      // DataTable Theme: improved table styling
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(TomzaColorsOrange.surfaceGrey),
        headingTextStyle: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TomzaColorsOrange.darkGrey,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: GoogleFonts.alexandria(
          fontSize: 14,
          color: TomzaColorsOrange.darkGrey,
        ),
        dividerThickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: TomzaColorsOrange.lightGrey,
        selectedColor: TomzaColorsOrange.accent,
        disabledColor: TomzaColorsOrange.mediumGrey.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: TomzaColorsOrange.mediumGrey.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.dark()],

      // Esquema de colores oscuro
      colorScheme: ColorScheme.fromSeed(
        seedColor: TomzaColorsBlue.darkPrimary,
        brightness: Brightness.dark,
        primary: TomzaColorsBlue.darkPrimary,
        onPrimary: Colors.white,
        secondary: TomzaColorsBlue.accent,
        onSecondary: Colors.white,
        surface: TomzaColorsBlue.darkSurface,
        onSurface: Colors.white,
        // background: const Color(0xFF121212), // deprecated
        // onBackground: Colors.white, // deprecated
        error: TomzaColorsBlue.errorRed,
        onError: Colors.white,
      ),

      // Scaffold Background (Oscuro)
      scaffoldBackgroundColor: TomzaColorsBlue.darkBackground,
      // AppBar Theme Oscuro
      appBarTheme: AppBarTheme(
        backgroundColor: TomzaColorsBlue.darkSurface,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme Oscuro
      cardTheme: CardThemeData(
        color: TomzaColorsBlue.darkCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton Theme Oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TomzaColorsBlue.light,
          foregroundColor: TomzaColorsBlue.darkGrey,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme Oscuro
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TomzaColorsBlue.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme Oscuro
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TomzaColorsBlue.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsBlue.darkPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: TomzaColorsBlue.errorRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: Colors.grey.shade400,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: Colors.grey.shade400,
        ),
      ),

      // Text Theme Oscuro
      textTheme: GoogleFonts.alexandriaTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.alexandria(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: GoogleFonts.alexandria(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displaySmall: GoogleFonts.alexandria(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineLarge: GoogleFonts.alexandria(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineMedium: GoogleFonts.alexandria(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineSmall: GoogleFonts.alexandria(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.alexandria(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.alexandria(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            titleSmall: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            bodyLarge: GoogleFonts.alexandria(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            bodySmall: GoogleFonts.alexandria(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade400,
            ),
            labelLarge: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            labelMedium: GoogleFonts.alexandria(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            labelSmall: GoogleFonts.alexandria(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),

      // Drawer Theme Oscuro
      drawerTheme: const DrawerThemeData(
        backgroundColor: TomzaColorsBlue.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme Oscuro
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme Oscuro
      chipTheme: ChipThemeData(
        backgroundColor: TomzaColorsBlue.darkCard,
        selectedColor: TomzaColorsBlue.accent,
        disabledColor: Colors.grey.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
