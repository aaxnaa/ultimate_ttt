import 'package:flutter/material.dart';

enum ThemeType { barbie, summer, winter, nighttime, galaxy, plant, ocean, midnight, minimalist, classic, natural, picnic, sunset }

class GameTheme {
  final String name;
  final Color background; // Bottom (Light)
  final Color secondaryBackground; // Top (Dark)
  final Color gridColor;
  final Color playerXColor;
  final Color playerOColor;
  final Color accentColor;
  final Color titleColor;
  final Color createTextColor;
  final Color joinTextColor;
  final Color accentColor2;
  final TextStyle textStyle;

  GameTheme({
    required this.name,
    required this.background,
    required this.secondaryBackground,
    required this.gridColor,
    required this.playerXColor,
    required this.playerOColor,
    required this.accentColor,
    required this.titleColor,
    required this.createTextColor,
    required this.joinTextColor,
    required this.accentColor2,
    required this.textStyle,
  });

  Color get contrastColor => background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  static GameTheme getTheme(ThemeType type) {
    const baseStyle = TextStyle(fontWeight: FontWeight.bold);

    switch (type) {
      case ThemeType.barbie:
        return GameTheme(
          name: 'Barbie',
          background: const Color(0xFFFFD1DC),
          secondaryBackground: const Color(0xFFE0218A),
          gridColor: const Color(0xFFFFFFFF),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF8DEEEE),
          accentColor: const Color(0xFFFF1493),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFE0218A),
          accentColor2: const Color(0xFFFCE4EC),
          textStyle: baseStyle,
        );
      case ThemeType.summer:
        return GameTheme(
          name: 'Summer',
          background: const Color(0xFFFFF9C4),
          secondaryBackground: const Color(0xFF0288D1),
          gridColor: const Color(0xFFB3E5FC),
          playerXColor: const Color(0xFFFFEB3B),
          playerOColor: const Color(0xFFFFFFFF),
          accentColor: const Color(0xFFFFD54F),
          titleColor: const Color(0xFF01579B),
          createTextColor: const Color(0xFF01579B),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF4CAF50),
          textStyle: baseStyle,
        );
      case ThemeType.winter:
        return GameTheme(
          name: 'Winter',
          background: const Color(0xFFE1F5FE),
          secondaryBackground: const Color(0xFF455A64),
          gridColor: const Color(0xFFB0BEC5),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF81D4FA),
          accentColor: const Color(0xFF263238),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF263238),
          accentColor2: const Color(0xFFECEFF1),
          textStyle: baseStyle,
        );
      case ThemeType.nighttime:
        return GameTheme(
          name: 'Nighttime',
          background: const Color(0xFF1A237E),
          secondaryBackground: const Color(0xFF0D47A1),
          gridColor: const Color(0xFF5C6BC0),
          playerXColor: const Color(0xFFF9D423),
          playerOColor: const Color(0xFFFFFFFF),
          accentColor: const Color(0xFF000051),
          titleColor: const Color(0xFFF9D423),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF1A237E),
          accentColor2: const Color(0xFFFFEB3B),
          textStyle: baseStyle,
        );
      case ThemeType.galaxy:
        return GameTheme(
          name: 'Galaxy',
          background: const Color(0xFF4A148C),
          secondaryBackground: const Color(0xFF000000),
          gridColor: const Color(0xFF7B1FA2),
          playerXColor: const Color(0xFF00FFFF),
          playerOColor: const Color(0xFFEA80FC),
          accentColor: const Color(0xFF311B92),
          titleColor: const Color(0xFF00FFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFFE040FB),
          textStyle: baseStyle,
        );
      case ThemeType.plant:
        return GameTheme(
          name: 'Plant',
          background: const Color(0xFFDCEDC8),
          secondaryBackground: const Color(0xFF33691E),
          gridColor: const Color(0xFF8BC34A),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF795548),
          accentColor: const Color(0xFF1B5E20),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF1B5E20),
          accentColor2: const Color(0xFFC5E1A5),
          textStyle: baseStyle,
        );
      case ThemeType.ocean:
        return GameTheme(
          name: 'Ocean',
          background: const Color(0xFFB2EBF2),
          secondaryBackground: const Color(0xFF006064),
          gridColor: const Color(0xFF4DD0E1),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFFFFCCBC),
          accentColor: const Color(0xFF00838F),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF006064),
          accentColor2: const Color(0xFFE0F7FA),
          textStyle: baseStyle,
        );
      case ThemeType.midnight:
        return GameTheme(
          name: 'Midnight',
          background: const Color(0xFF000000),
          secondaryBackground: const Color(0xFF1A237E),
          gridColor: const Color(0xFF303F9F),
          playerXColor: const Color(0xFFFFD700),
          playerOColor: const Color(0xFFC0C0C0),
          accentColor: const Color(0xFF000051),
          titleColor: const Color(0xFFFFD700),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF283593),
          textStyle: baseStyle,
        );
      case ThemeType.minimalist:
        return GameTheme(
          name: 'Minimalist',
          background: const Color(0xFFFAFAFA),
          secondaryBackground: const Color(0xFF212121),
          gridColor: const Color(0xFF424242),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFFBDBDBD),
          accentColor: const Color(0xFF000000),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF000000),
          accentColor2: const Color(0xFFEEEEEE),
          textStyle: baseStyle,
        );
      case ThemeType.classic:
        return GameTheme(
          name: 'Classic',
          background: const Color(0xFFFFFFFF),
          secondaryBackground: const Color(0xFFE0E0E0),
          gridColor: const Color(0xFFBDBDBD),
          playerXColor: const Color(0xFFD32F2F),
          playerOColor: const Color(0xFF1976D2),
          accentColor: const Color(0xFF212121),
          titleColor: const Color(0xFF212121),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF757575),
          textStyle: baseStyle,
        );
      case ThemeType.natural:
        return GameTheme(
          name: 'Natural',
          background: const Color(0xFFF5F5DC),
          secondaryBackground: const Color(0xFF4E342E),
          gridColor: const Color(0xFFA1887F),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF8BC34A),
          accentColor: const Color(0xFF3E2723),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF3E2723),
          accentColor2: const Color(0xFFD7CCC8),
          textStyle: baseStyle,
        );
      case ThemeType.picnic:
        return GameTheme(
          name: 'Picnic',
          background: const Color(0xFFFFF9C4),
          secondaryBackground: const Color(0xFFD32F2F),
          gridColor: const Color(0xFFEF9A9A),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFFFFEB3B),
          accentColor: const Color(0xFFB71C1C),
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFFF44336),
          textStyle: baseStyle,
        );
      case ThemeType.sunset:
        return GameTheme(
          name: 'Sunset',
          background: const Color(0xFFFFB74D),
          secondaryBackground: const Color(0xFF4A148C),
          gridColor: const Color(0xFF9575CD),
          playerXColor: const Color(0xFFFFEB3B),
          playerOColor: const Color(0xFFFFFFFF),
          accentColor: const Color(0xFF311B92),
          titleColor: const Color(0xFFFFD54F),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFFBA68C8),
          textStyle: baseStyle,
        );
    }
  }
}
