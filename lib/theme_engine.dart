import 'package:flutter/material.dart';

enum ThemeType { picnic, barbie, sunset, summer, plant, ocean, nighttime, winter, natural, classic, minimalist, galaxy, midnight }

class GameTheme {
  final String name;
  final Color background; // Bottom
  final Color secondaryBackground; // Top
  final Color gridColor;
  final Color gridHighlightColor;
  final Color playerXColor;
  final Color playerOColor;
  final Color xTurnColor;
  final Color oTurnColor;
  final Color versionColor;
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
    required this.gridHighlightColor,
    required this.playerXColor,
    required this.playerOColor,
    required this.xTurnColor,
    required this.oTurnColor,
    required this.versionColor,
    required this.titleColor,
    required this.createTextColor,
    required this.joinTextColor,
    required this.accentColor2,
    required this.textStyle,
  });

  Color get accentColor => gridHighlightColor;
  Color get contrastColor => titleColor;

  static GameTheme getTheme(ThemeType type) {
    const baseStyle = TextStyle(fontWeight: FontWeight.bold);

    switch (type) {
      case ThemeType.picnic:
        return GameTheme(
          name: 'Picnic',
          secondaryBackground: const Color(0xFFD32F2F),
          background: const Color(0xFFFFF9C4),
          gridColor: const Color(0xFFB71C1C),
          gridHighlightColor: const Color(0xFFFBC02D),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFFFBC02D),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFFFBC02D),
          versionColor: Colors.black,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFFB71C1C),
          textStyle: baseStyle,
        );
      case ThemeType.barbie:
        return GameTheme(
          name: 'Barbie',
          secondaryBackground: const Color(0xFFE0218A),
          background: const Color(0xFFFFD1DC),
          gridColor: const Color(0xFFE0218A),
          gridHighlightColor: const Color(0xFFFF1493),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF004D40),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFF004D40),
          versionColor: Colors.black,
          titleColor: const Color(0xFF4A0429),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFE0218A),
          accentColor2: const Color(0xFFE0218A),
          textStyle: baseStyle,
        );
      case ThemeType.sunset:
        return GameTheme(
          name: 'Sunset',
          secondaryBackground: const Color(0xFF4A148C),
          background: const Color(0xFFFFB74D),
          gridColor: const Color(0xFF311B92),
          gridHighlightColor: const Color(0xFFFFD600),
          playerXColor: const Color(0xFFFFEB3B),
          playerOColor: const Color(0xFFFFFFFF),
          xTurnColor: const Color(0xFFFFEB3B),
          oTurnColor: const Color(0xFFFFFFFF),
          versionColor: Colors.black,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF311B92),
          textStyle: baseStyle,
        );
      case ThemeType.summer:
        return GameTheme(
          name: 'Summer',
          secondaryBackground: const Color(0xFF0288D1),
          background: const Color(0xFFFFF9C4),
          gridColor: const Color(0xFF01579B),
          gridHighlightColor: const Color(0xFFF57C00),
          playerXColor: const Color(0xFFFFD600),
          playerOColor: const Color(0xFFFFFFFF),
          xTurnColor: const Color(0xFFFFD600),
          oTurnColor: const Color(0xFFFFFFFF),
          versionColor: Colors.black,
          titleColor: const Color(0xFF012E47),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF01579B),
          textStyle: baseStyle,
        );
      case ThemeType.plant:
        return GameTheme(
          name: 'Plant',
          secondaryBackground: const Color(0xFF33691E),
          background: const Color(0xFFDCEDC8),
          gridColor: const Color(0xFF1B5E20),
          gridHighlightColor: const Color(0xFF795548),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF3E2723),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFF3E2723),
          versionColor: Colors.black,
          titleColor: const Color(0xFF1B2E0B),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF1B5E20),
          accentColor2: const Color(0xFF1B5E20),
          textStyle: baseStyle,
        );
      case ThemeType.ocean:
        return GameTheme(
          name: 'Ocean',
          secondaryBackground: const Color(0xFF006064),
          background: const Color(0xFFB2EBF2),
          gridColor: const Color(0xFF004D40),
          gridHighlightColor: const Color(0xFFE64A19),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFFBF360C),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFFBF360C),
          versionColor: Colors.black,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF006064),
          accentColor2: const Color(0xFF006064),
          textStyle: baseStyle,
        );
      case ThemeType.nighttime:
        return GameTheme(
          name: 'Nighttime',
          secondaryBackground: const Color(0xFF0D47A1),
          background: const Color(0xFF1A237E),
          gridColor: const Color(0xFF5C6BC0),
          gridHighlightColor: const Color(0xFFFFEB3B),
          playerXColor: const Color(0xFFFFEB3B),
          playerOColor: const Color(0xFFFFFFFF),
          xTurnColor: const Color(0xFFFFEB3B),
          oTurnColor: const Color(0xFFFFFFFF),
          versionColor: Colors.white,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF1A237E),
          accentColor2: const Color(0xFF1A237E),
          textStyle: baseStyle,
        );
      case ThemeType.winter:
        return GameTheme(
          name: 'Winter',
          secondaryBackground: const Color(0xFF455A64),
          background: const Color(0xFFE1F5FE),
          gridColor: const Color(0xFF263238),
          gridHighlightColor: const Color(0xFF01579B),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF01579B),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFF01579B),
          versionColor: Colors.black,
          titleColor: const Color(0xFF1A2327),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF263238),
          accentColor2: const Color(0xFF263238),
          textStyle: baseStyle,
        );
      case ThemeType.natural:
        return GameTheme(
          name: 'Natural',
          secondaryBackground: const Color(0xFF4E342E),
          background: const Color(0xFFF5F5DC),
          gridColor: const Color(0xFF3E2723),
          gridHighlightColor: const Color(0xFF8BC34A),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF2E7D32),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFF2E7D32),
          versionColor: Colors.black,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF3E2723),
          accentColor2: const Color(0xFF3E2723),
          textStyle: baseStyle,
        );
      case ThemeType.classic:
        return GameTheme(
          name: 'Classic',
          secondaryBackground: const Color(0xFFE0E0E0),
          background: const Color(0xFFFFFFFF),
          gridColor: const Color(0xFF9E9E9E),
          gridHighlightColor: const Color(0xFF212121),
          playerXColor: const Color(0xFFD32F2F),
          playerOColor: const Color(0xFF1976D2),
          xTurnColor: const Color(0xFFD32F2F),
          oTurnColor: const Color(0xFF1976D2),
          versionColor: Colors.black,
          titleColor: const Color(0xFF212121),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF757575),
          textStyle: baseStyle,
        );
      case ThemeType.minimalist:
        return GameTheme(
          name: 'Minimalist',
          secondaryBackground: const Color(0xFF212121),
          background: const Color(0xFFFAFAFA),
          gridColor: const Color(0xFF424242),
          gridHighlightColor: const Color(0xFF000000),
          playerXColor: const Color(0xFFFFFFFF),
          playerOColor: const Color(0xFF000000),
          xTurnColor: const Color(0xFFFFFFFF),
          oTurnColor: const Color(0xFF000000),
          versionColor: Colors.black,
          titleColor: const Color(0xFFFFFFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFF000000),
          accentColor2: const Color(0xFF212121),
          textStyle: baseStyle,
        );
      case ThemeType.galaxy:
        return GameTheme(
          name: 'Galaxy',
          secondaryBackground: const Color(0xFF000000),
          background: const Color(0xFF4A148C),
          gridColor: const Color(0xFF7B1FA2),
          gridHighlightColor: const Color(0xFF00FFFF),
          playerXColor: const Color(0xFF00FFFF),
          playerOColor: const Color(0xFFEA80FC),
          xTurnColor: const Color(0xFF00FFFF),
          oTurnColor: const Color(0xFFEA80FC),
          versionColor: Colors.white,
          titleColor: const Color(0xFF00FFFF),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF311B92),
          textStyle: baseStyle,
        );
      case ThemeType.midnight:
      default:
        return GameTheme(
          name: 'Midnight',
          secondaryBackground: const Color(0xFF000000),
          background: const Color(0xFF1A237E),
          gridColor: const Color(0xFF303F9F),
          gridHighlightColor: const Color(0xFFFFD700),
          playerXColor: const Color(0xFFFFD700),
          playerOColor: const Color(0xFFE0E0E0),
          xTurnColor: const Color(0xFFFFD700),
          oTurnColor: const Color(0xFFE0E0E0),
          versionColor: Colors.white,
          titleColor: const Color(0xFFFFD700),
          createTextColor: const Color(0xFFFFFFFF),
          joinTextColor: const Color(0xFFFFFFFF),
          accentColor2: const Color(0xFF283593),
          textStyle: baseStyle,
        );
    }
  }
}
