import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/icon_widget.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/row_icons.dart';

class ButtomNavigationBar extends StatelessWidget {
  const ButtomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return IconGroup(
      spaceBetween: 19,
      isVertical: false,
      icons: [
        IconWidget(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
          isHaveBackgroundColor: true,
          icon: Icon(Icons.home, size: 28, color: AppColors.primary200),
          backgroundColor: AppColors.primaryColor,
        ),
        IconWidget(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          isHaveBackgroundColor: true,
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.shopping_basket_sharp, size: 28),
        ),
        IconWidget(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          isHaveBackgroundColor: true,
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.search, size: 28),
        ),
        IconWidget(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          isHaveBackgroundColor: true,
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.settings, size: 28),
        ),
      ],
    );
  }
}
