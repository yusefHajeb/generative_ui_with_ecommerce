import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@Riverpod()
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeModeType build() {
    return ThemeModeType.light;
  }

  void setThemeMode(ThemeModeType mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
  }
}

enum ThemeModeType { light, dark }

@riverpod
class ThemeSeedColor extends _$ThemeSeedColor {
  @override
  Color build() {
    return Colors.blue;
  }

  void setSeedColor(String colorName) {
    final colorLower = colorName.toLowerCase().trim();

    Color? selectedColor = _parseHexColor(colorLower);

    selectedColor ??= _parseRgbColor(colorLower);

    selectedColor ??= _getNamedColor(colorLower);

    state = selectedColor ?? Colors.blue;
  }

  Color? _parseHexColor(String colorString) {
    try {
      String hex = colorString
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll(' ', '');

      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Color? _parseRgbColor(String colorString) {
    try {
      final rgbPattern = RegExp(
        r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)',
      );
      final match = rgbPattern.firstMatch(colorString);

      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final a = match.group(4) != null
            ? (double.parse(match.group(4)!) * 255).round()
            : 255;

        return Color.fromARGB(a, r, g, b);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Color? _getNamedColor(String colorName) {
    return null;
  }

  void setColor(Color color) {
    state = color;
  }
}
