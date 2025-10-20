import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/theme/text_theme.dart';

class AppTheme {
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
    brightness: Brightness.light,
    primary: AppColors.primaryColor,

    // use variables from appColors for best colorScheme , primary ...
    onPrimary: AppColors.primary500,
    secondary: Colors.white,

    surface: AppColors.primary50,

    onSurface: AppColors.primary500,
  );
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
    brightness: Brightness.dark,
    primary: AppColors.primaryColor,
    onPrimary: AppColors.primary500,
  );
  static ThemeData getThemeData({required bool themeModeIsDark}) {
    return themeModeIsDark ? darkTheme() : lightTheme();
  }

  static ThemeData lightTheme() => ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: lightSystemUiOverlayStyle,
      iconTheme: IconThemeData(color: AppColors.iconColor),
      backgroundColor: AppColors.primary100,
    ),

    primaryColor: AppColors.primaryColor,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    fontFamily: 'IBM Plex Sans Arabic',
    unselectedWidgetColor: Colors.grey[300],
    canvasColor: AppColors.white,
    dividerColor: Colors.grey[300],
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Colors.white,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    highlightColor: Colors.black.withValues(alpha: 0.1),
    splashColor: Colors.black.withValues(alpha: 0.1),
    textTheme: AppTextTheme.textTheme(lightColorScheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0.0),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primaryColor.withValues(alpha: 0.7);
          }
          return AppColors.primary400;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return (states.contains(WidgetState.pressed))
              ? AppColors.primary400
              : AppColors.primary100;
        }),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1),
        ),
        overlayColor: WidgetStateProperty.all<Color>(AppColors.primary50),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(5),
      thumbColor: WidgetStateProperty.all(Colors.grey[300]),
    ),
    iconTheme: IconThemeData(color: Colors.grey[400], size: 30),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[200],
      filled: true,
      isDense: false,

      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      focusColor: AppColors.primaryColor,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary400, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
      hintStyle: TextStyle(color: AppColors.primary400),
    ),
    cardColor: Colors.grey[200],
  );

  static ThemeData darkTheme() => ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: darkSystemUiOverlayStyle,
      backgroundColor: AppColors.primaryColor,
      iconTheme: IconThemeData(color: AppColors.black),
    ),

    primaryColor: AppColors.primaryColor,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    fontFamily: 'IBM Plex Sans Arabic',
    dividerColor: AppColors.primaryColor,
    iconTheme: IconThemeData(color: AppColors.primaryColor.withValues(alpha: 0.5), size: 30),
    unselectedWidgetColor: Colors.grey[300],
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.white24,
      filled: true,
      hintStyle: TextStyle(color: Colors.white38),
    ),
    textTheme: AppTextTheme.textTheme(darkColorScheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0.0),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primaryColor.withValues(alpha: 0.6);
          }
          return AppColors.primary50;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return (states.contains(WidgetState.disabled))
              ? AppColors.primary400
              : AppColors.primary300;
        }),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1),
        ),
        overlayColor: WidgetStateProperty.all<Color>(AppColors.primary400),
      ),
    ),
    splashColor: Colors.black.withValues(alpha: 0.1),
    highlightColor: AppColors.primaryColor.withValues(alpha: 0.5),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: const Color(0xff1B2349),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      backgroundColor: AppColors.primary100,
    ),
    cardColor: AppColors.primaryColor.withValues(alpha: 0.2),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(5),
      thumbColor: WidgetStateProperty.all(AppColors.primaryColor.withValues(alpha: 0.5)),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.white,
      brightness: Brightness.dark,
      outline: AppColors.primary300,
    ),
  );

  static SystemUiOverlayStyle darkSystemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xff10122C),
  );

  static SystemUiOverlayStyle lightSystemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  );
}
