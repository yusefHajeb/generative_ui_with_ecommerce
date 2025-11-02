import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';

class DialogRouteContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? widget;
  final bool isTransaction;
  const DialogRouteContainer({
    super.key,
    this.height,
    this.width,
    this.widget,
    this.isTransaction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isTransaction ? Colors.transparent : context.themeData.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(8), child: widget),
        ),
      ],
    );
  }
}
