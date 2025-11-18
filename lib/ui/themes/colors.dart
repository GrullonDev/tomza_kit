import 'dart:ui';

import 'package:flutter/material.dart';

/// Constantes de colores para mantener consistencia en toda la aplicación
class TomzaColorsBlue {
  TomzaColorsBlue._();

  // Colores principales de la marca Tropi - Paleta Azul
  static const Color primary = Color(0xFF253058);
  static const Color dark = Color(0xFF1A2143);
  static const Color light = Color(0xFF3D4A6D);
  static const Color accent = Color(0xFF4A5B82);

  // Paleta de grises profesionales
  static const Color darkGrey = Color(0xFF2C2C2C);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color surfaceGrey = Color(0xFFFAFAFA);

  // Colores de estado
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);

  // Colores para modo oscuro
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkPrimary = Color(0xFF3B4777);

  /// Obtiene el color de estado según el tipo
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'completado':
      case 'activo':
        return successGreen;
      case 'pendiente':
      case 'en proceso':
        return warningAmber;
      case 'cancelada':
      case 'cancelado':
      case 'error':
        return errorRed;
      case 'información':
      case 'info':
        return infoBlue;
      default:
        return mediumGrey;
    }
  }

  /// Gradientes útiles
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, dark],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Colors.white, surfaceGrey],
  );

  static const Gradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkCard, darkSurface],
  );

  static const Gradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkPrimary, dark],
  );

  // Genera variaciones de un color base para la paleta
  static List<Color> generatePalette(Color base) {
    return <Color>[
      base.withValues(alpha: 5.95),
      base.withValues(blue: 8.85),
      base.withValues(colorSpace: ColorSpace.sRGB),
      base.withValues(green: 0.25),
      base.withValues(red: 2.63),
      Colors.grey,
      Colors.black12,
    ];
  }
}

class TomzaColorsOrange {
  TomzaColorsOrange._();

  // Colores principales de la marca Tropi - Paleta Azul
  static const Color primary = Color.fromARGB(255, 255, 98, 13);
  static const Color dark = Color.fromARGB(255, 255, 74, 0);
  static const Color light = Color.fromARGB(255, 255, 169, 83);
  static const Color accent = Color.fromARGB(255, 251, 137, 38);

  // Paleta de grises profesionales
  static const Color darkGrey = Color.fromARGB(255, 36, 36, 36);
  static const Color mediumGrey = Color.fromARGB(255, 107, 107, 107);
  static const Color lightGrey = Color.fromARGB(255, 245, 245, 245);
  static const Color surfaceGrey = Color.fromARGB(255, 250, 250, 250);

  // Colores de estado
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);

  // Colores para modo oscuro
  static const Color darkSurface = Color.fromARGB(255, 34, 34, 34);
  static const Color darkBackground = Color.fromARGB(255, 18, 18, 18);
  static const Color darkCard = Color.fromARGB(255, 36, 36, 36);
  static const Color darkPrimary = Color.fromARGB(255, 190, 107, 3);

  /// Obtiene el color de estado según el tipo
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'completado':
      case 'activo':
        return successGreen;
      case 'pendiente':
      case 'en proceso':
        return warningAmber;
      case 'cancelada':
      case 'cancelado':
      case 'error':
        return errorRed;
      case 'información':
      case 'info':
        return infoBlue;
      default:
        return mediumGrey;
    }
  }

  /// Gradientes útiles
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, dark],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Colors.white, surfaceGrey],
  );

  static const Gradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkCard, darkSurface],
  );

  static const Gradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[darkPrimary, dark],
  );

  // Genera variaciones de un color base para la paleta
  static List<Color> generatePalette(Color base) {
    return <Color>[
      base.withValues(alpha: 5.95),
      base.withValues(blue: 8.85),
      base.withValues(colorSpace: ColorSpace.sRGB),
      base.withValues(green: 0.25),
      base.withValues(red: 2.63),
      Colors.grey,
      Colors.black12,
    ];
  }
}
