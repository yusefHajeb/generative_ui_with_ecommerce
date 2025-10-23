import 'package:flutter/material.dart';

extension ContextExtension<T> on BuildContext {
  ThemeData get themeData => Theme.of(this);
  TextTheme get textTheme => themeData.textTheme;
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get height => mediaQuerySize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get width => mediaQuerySize.width;
  bool get isSmallDevice => height < 600;
  bool get isTablet =>
      mediaQuerySize.width < 1100 && mediaQuerySize.width >= 650;
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
