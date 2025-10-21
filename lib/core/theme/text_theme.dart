import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

class AppTextTheme {
  static const String defaultFontFamily = 'IBM Plex Sans Arabic';
  static const String defaultFontFamilyMedium = 'IBM Plex Sans Arabic Medium';

  static TextStyle baseTextStyle = const TextStyle(
    color: Colors.blueGrey,
    fontFamily: defaultFontFamily,
    fontSize: 14,
  );

  static TextStyle titleMedium = baseTextStyle.copyWith(
    color: AppColors.white,
    fontSize: 17,
    fontFamily: defaultFontFamilyMedium,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleSmall = baseTextStyle.copyWith(fontSize: 14);

  static TextStyle titleLarge = baseTextStyle.copyWith(fontSize: 17);
  static TextStyle bodyMedium = baseTextStyle.copyWith(
    fontSize: 16,
    fontFamily: defaultFontFamilyMedium,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );
  static TextStyle bodySmall = baseTextStyle.copyWith(fontSize: 12);
  static TextStyle bodyLarge = baseTextStyle.copyWith(
    color: AppColors.white,
    fontSize: 20,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.w400,
  );
  static TextStyle displayLarge = baseTextStyle.copyWith(fontSize: 16, height: 1.25);
  static TextStyle displayMedium = baseTextStyle.copyWith(
    fontSize: 16,
    fontFamily: defaultFontFamilyMedium,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );
  static TextStyle displaySmall = baseTextStyle.copyWith(fontSize: 12);
  static TextStyle headlineLarge = baseTextStyle.copyWith(fontSize: 20);
  static TextStyle headlineMedium = baseTextStyle.copyWith(
    fontSize: 18,
    fontFamily: defaultFontFamilyMedium,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static TextTheme textTheme(ColorScheme color) {
    baseTextStyle = baseTextStyle.copyWith(color: color.onSurface);

    return TextTheme(
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: baseTextStyle.copyWith(fontSize: 16),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontFamily: defaultFontFamilyMedium,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
