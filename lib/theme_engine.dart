import 'package:flutter/material.dart';

enum ThemeType { barbie, summer, winter, nighttime, galaxy, classic, plant, natural, minimalist, ocean, picnic, sunset, midnight }

class GameTheme {
  final String name;
  final Color background;
  final Color secondaryBackground; // For the Ombre effect
  final Color gridColor;
  final Color playerXColor;
  final Color playerOColor;
  final Color accentColor;
  final TextStyle textStyle;

  GameTheme({
    required this.name,
    required this.background,
    required this.secondaryBackground,
    required this.gridColor,
    required this.playerXColor,
    required this.playerOColor,
    required this.accentColor,
    required this.textStyle,
  });

  Color get contrastColor => background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  static GameTheme getTheme(ThemeType type) {
    // We are using high-quality system fonts to ensure 100% compatibility across all Flutter versions.
    const baseStyle = TextStyle(fontWeight: FontWeight.bold);

    switch (type) {
      case ThemeType.barbie:
        return GameTheme(
          name: 'Barbie',
          background: const Color(0xFFFFC1CC), 
          secondaryBackground: const Color(0xFFF48FB1), 
          gridColor: const Color(0xFFD81B60),
          playerXColor: const Color(0xFF880E4F), 
          playerOColor: Colors.white,            
          accentColor: const Color(0xFFD81B60),
          textStyle: baseStyle,
        );
      case ThemeType.summer:
        return GameTheme(
          name: 'Summer',
          background: const Color(0xFFFFF9C4), 
          secondaryBackground: const Color(0xFFFFECB3), 
          gridColor: const Color(0xFFFF6F00),
          playerXColor: const Color(0xFFBF360C), 
          playerOColor: const Color(0xFF006064), 
          accentColor: const Color(0xFFFF6F00),
          textStyle: baseStyle,
        );
      case ThemeType.winter:
        return GameTheme(
          name: 'Winter',
          background: const Color(0xFFE3F2FD), 
          secondaryBackground: const Color(0xFFBBDEFB), 
          gridColor: const Color(0xFF1976D2),
          playerXColor: const Color(0xFF0D47A1), 
          playerOColor: const Color(0xFFD81B60), 
          accentColor: const Color(0xFF1976D2),
          textStyle: baseStyle,
        );
      case ThemeType.nighttime:
        return GameTheme(
          name: 'Nighttime',
          background: const Color(0xFF1A237E), 
          secondaryBackground: const Color(0xFF000051), 
          gridColor: const Color(0xFF3F51B5),
          playerXColor: const Color(0xFFFFEB3B), 
          playerOColor: const Color(0xFF00E5FF), 
          accentColor: const Color(0xFF7986CB),
          textStyle: baseStyle,
        );
      case ThemeType.galaxy:
        return GameTheme(
          name: 'Galaxy',
          background: const Color(0xFF0D0221), 
          secondaryBackground: const Color(0xFF261447), 
          gridColor: const Color(0xFF7000FF).withOpacity(0.3),
          playerXColor: const Color(0xFF7000FF), 
          playerOColor: const Color(0xFF00FDFF), 
          accentColor: const Color(0xFFFF00E0),
          textStyle: baseStyle,
        );
      case ThemeType.plant:
        return GameTheme(
          name: 'Plant',
          background: const Color(0xFFE8F5E9), 
          secondaryBackground: const Color(0xFFC8E6C9), 
          gridColor: const Color(0xFF2E7D32),
          playerXColor: const Color(0xFF1B5E20), 
          playerOColor: const Color(0xFFBF360C), 
          accentColor: const Color(0xFF4CAF50),
          textStyle: baseStyle,
        );
      case ThemeType.natural:
        return GameTheme(
          name: 'Natural',
          background: const Color(0xFFEFEBE9), 
          secondaryBackground: const Color(0xFFD7CCC8), 
          gridColor: const Color(0xFF5D4037),
          playerXColor: const Color(0xFF3E2723), 
          playerOColor: const Color(0xFF795548), 
          accentColor: const Color(0xFF5D4037),
          textStyle: baseStyle,
        );
      case ThemeType.minimalist:
        return GameTheme(
          name: 'Minimalist',
          background: const Color(0xFFFFFFFF), 
          secondaryBackground: const Color(0xFFF5F5F5), 
          gridColor: const Color(0xFF000000),
          playerXColor: Colors.black,            
          playerOColor: Colors.black,            
          accentColor: Colors.black,
          textStyle: baseStyle,
        );
      case ThemeType.ocean:
        return GameTheme(
          name: 'Ocean',
          background: const Color(0xFFE0F7FA), 
          secondaryBackground: const Color(0xFF80DEEA), 
          gridColor: const Color(0xFF01579B),
          playerXColor: const Color(0xFF01579B), 
          playerOColor: const Color(0xFF00B0FF), 
          accentColor: const Color(0xFF00ACC1),
          textStyle: baseStyle,
        );
      case ThemeType.picnic:
        return GameTheme(
          name: 'Picnic',
          background: const Color(0xFFFFFDE7), 
          secondaryBackground: const Color(0xFFFFF9C4), 
          gridColor: const Color(0xFFD32F2F),
          playerXColor: const Color(0xFFD81B60), 
          playerOColor: const Color(0xFFE65100), 
          accentColor: const Color(0xFFFBC02D),
          textStyle: baseStyle,
        );
      case ThemeType.sunset:
        return GameTheme(
          name: 'Sunset',
          background: const Color(0xFF4A148C), 
          secondaryBackground: const Color(0xFFFF6F00), 
          gridColor: const Color(0xFFFFB74D),
          playerXColor: const Color(0xFFEA80FC), 
          playerOColor: const Color(0xFFFFD180), 
          accentColor: const Color(0xFFFF4081),
          textStyle: baseStyle,
        );
      case ThemeType.midnight:
        return GameTheme(
          name: 'Midnight',
          background: const Color(0xFF000000),
          secondaryBackground: const Color(0xFF1A1A1A),
          gridColor: Colors.white10,
          playerXColor: Colors.white,
          playerOColor: Colors.redAccent,
          accentColor: Colors.white,
          textStyle: baseStyle,
        );
      case ThemeType.classic:
      default:
        return GameTheme(
          name: 'Classic',
          background: Colors.white,
          secondaryBackground: Colors.white70,
          gridColor: Colors.black12,
          playerXColor: Colors.blue,
          playerOColor: Colors.red,
          accentColor: Colors.grey,
          textStyle: baseStyle,
        );
    }
  }
}
