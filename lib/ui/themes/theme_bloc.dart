import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tomza_kit/ui/themes/colors.dart';
import 'package:tomza_kit/ui/themes/status_color.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.light()],

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: TomzaColors.primary,
        primary: TomzaColors.primary,
        onPrimary: Colors.white,
        secondary: TomzaColors.dark,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: TomzaColors.darkGrey,
        // background: surfaceGrey, // deprecated
        // onBackground: darkGrey, // deprecated
        error: TomzaColors.errorRed,
        onError: Colors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Colors.white,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: TomzaColors.primary,
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
        selectedColor: TomzaColors.primary,
        iconColor: TomzaColors.primary,
        textColor: TomzaColors.darkGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TomzaColors.primary,
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
        backgroundColor: TomzaColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TomzaColors.surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColors.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: TomzaColors.mediumGrey.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TomzaColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TomzaColors.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColors.mediumGrey,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: TomzaColors.mediumGrey,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.alexandriaTextTheme().copyWith(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: TomzaColors.darkGrey,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: TomzaColors.darkGrey,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TomzaColors.darkGrey,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColors.darkGrey,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: TomzaColors.darkGrey,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: TomzaColors.darkGrey,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: TomzaColors.mediumGrey,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TomzaColors.mediumGrey,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: TomzaColors.mediumGrey,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: TomzaColors.mediumGrey,
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
        color: TomzaColors.mediumGrey.withValues(alpha: 0.5),
        thickness: 1,
        space: 0.5,
      ),
      // DataTable Theme: improved table styling
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(TomzaColors.surfaceGrey),
        headingTextStyle: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TomzaColors.darkGrey,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: GoogleFonts.alexandria(
          fontSize: 14,
          color: TomzaColors.darkGrey,
        ),
        dividerThickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: TomzaColors.lightGrey,
        selectedColor: TomzaColors.accent,
        disabledColor: TomzaColors.mediumGrey.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: TomzaColors.mediumGrey.withValues(alpha: 0.3)),
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
        seedColor: TomzaColors.darkPrimary,
        brightness: Brightness.dark,
        primary: TomzaColors.darkPrimary,
        onPrimary: Colors.white,
        secondary: TomzaColors.accent,
        onSecondary: Colors.white,
        surface: TomzaColors.darkSurface,
        onSurface: Colors.white,
        // background: const Color(0xFF121212), // deprecated
        // onBackground: Colors.white, // deprecated
        error: TomzaColors.errorRed,
        onError: Colors.white,
      ),

      // Scaffold Background (Oscuro)
      scaffoldBackgroundColor: TomzaColors.darkBackground,
      // AppBar Theme Oscuro
      appBarTheme: AppBarTheme(
        backgroundColor: TomzaColors.darkSurface,
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
        color: TomzaColors.darkCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton Theme Oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TomzaColors.light,
          foregroundColor: TomzaColors.darkGrey,
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
        backgroundColor: TomzaColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme Oscuro
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TomzaColors.darkCard,
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
            color: TomzaColors.darkPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TomzaColors.errorRed, width: 2),
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
        backgroundColor: TomzaColors.darkSurface,
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
        backgroundColor: TomzaColors.darkCard,
        selectedColor: TomzaColors.accent,
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
