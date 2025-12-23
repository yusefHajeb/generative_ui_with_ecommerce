import 'package:flutter/material.dart';

// ignore: must_be_immutable
class IconWidget extends StatelessWidget {
  final bool isHaveBackgroundColor;
  Color? backgroundColor;
  EdgeInsetsGeometry padding;
  double? radius;

  final Widget icon;
  IconWidget({
    this.radius = 30,
    super.key,
    required this.isHaveBackgroundColor,
    required this.icon,
    this.padding = const EdgeInsets.all(5),
    this.backgroundColor = const Color(0xffF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 30)),
        color: backgroundColor,
      ),
      child: icon,
    );
  }
}
