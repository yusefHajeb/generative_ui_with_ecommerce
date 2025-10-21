import 'package:flutter/material.dart';

class IconGroup extends StatelessWidget {
  final List<Widget> icons;

  final double spaceBetween;

  final double? height;

  final bool isVertical;
  final Color? backgrounndColor;

  static const double _defaultSpacing = 8.0;
  static const double _containerPadding = 6.0;
  static const double _borderRadius = 30.0;
  static const double _backgroundOpacity = 0.6;

  const IconGroup({
    super.key,
    required this.icons,
    this.height,

    this.backgrounndColor,
    this.spaceBetween = _defaultSpacing,
    this.isVertical = false,
  }) : assert(icons.length > 0, 'Icons list cannot be empty');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(_containerPadding),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        color:
            backgrounndColor ?? ((Colors.grey[200] ?? Colors.grey)).withOpacity(_backgroundOpacity),
      ),
      child: isVertical
          ? _VerticalIconList(icons: icons, spaceBetween: spaceBetween)
          : _HorizontalIconList(icons: icons, spaceBetween: spaceBetween),
    );
  }
}

class _HorizontalIconList extends StatelessWidget {
  const _HorizontalIconList({required this.icons, required this.spaceBetween});

  final List<Widget> icons;
  final double spaceBetween;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          icons.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index != icons.length - 1 ? spaceBetween : 0),
            child: icons[index],
          ),
        ),
      ),
    );
  }
}

/// Private widget that arranges icons vertically in a Column.
class _VerticalIconList extends StatelessWidget {
  const _VerticalIconList({required this.icons, required this.spaceBetween});

  final List<Widget> icons;
  final double spaceBetween;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        icons.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index != icons.length - 1 ? spaceBetween : 0),
          child: icons[index],
        ),
      ),
    );
  }
}
