import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

import '../providers/bottom_navigation_provider.dart';

class ButtomNavigationBar extends ConsumerStatefulWidget {
  const ButtomNavigationBar({super.key});

  @override
  ConsumerState<ButtomNavigationBar> createState() => _ButtomNavigationBarState();
}

class IconButtomNavigationItem {
  final IconData icon;
  final String label;

  IconButtomNavigationItem({required this.icon, required this.label});
}

class _ButtomNavigationBarState extends ConsumerState<ButtomNavigationBar> {
  final List<IconButtomNavigationItem> _icons = [
    IconButtomNavigationItem(icon: Icons.home, label: 'الرئيسيه'),
    IconButtomNavigationItem(icon: Icons.shopping_basket_sharp, label: 'الفئات'),
    IconButtomNavigationItem(icon: Icons.search, label: 'البحث'),
    IconButtomNavigationItem(icon: Icons.settings, label: 'الإعدادات'),
  ];

  static const double _iconSize = 28.0;
  static const double _selectedPaddingH = 25.0;
  static const double _unselectedPaddingH = 20.0;
  static const double _spaceBetween = 19.0;
  static const double _containerPadding = 2.0;
  static const double _borderRadius = 30.0;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  late bool isEndedAnimation;

  /// Calculates the width of an icon container based on selection state
  double _getIconWidth(bool isSelected) {
    return (isSelected ? _selectedPaddingH : _unselectedPaddingH) * 2 + _iconSize + 8;
  }

  /// Calculates the left position for the sliding background
  double _calculateBackgroundPosition(int index) {
    double position = 0;

    for (int i = 0; i < index; i++) {
      position += _getIconWidth(false) + _spaceBetween;
    }

    return position;
  }

  @override
  void initState() {
    isEndedAnimation = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavigationIndexProvider);
    return Container(
      padding: const EdgeInsets.all(_containerPadding),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        color: (Colors.grey[800] ?? Colors.grey).withOpacity(0.1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            left: _calculateBackgroundPosition(selectedIndex),
            top: 0,
            bottom: 0,
            onEnd: () {
              setState(() {
                isEndedAnimation = true;
              });
            },
            child: Container(
              width: _getIconWidth(true),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
                color: Colors.black12.withOpacity(0.37),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_icons.length, (index) {
              final isSelected = selectedIndex == index;
              return Padding(
                padding: EdgeInsets.only(right: index != _icons.length - 1 ? _spaceBetween : 0),
                child: _buildNavigationIcon(
                  buttomItem: _icons[index],
                  index: index,
                  isSelected: isSelected,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationIcon({
    required IconButtomNavigationItem buttomItem,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (index != ref.read(bottomNavigationIndexProvider)) {
          setState(() {
            isEndedAnimation = false;
          });
        }

        ref.read(bottomNavigationIndexProvider.notifier).setIndex(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? _selectedPaddingH : _unselectedPaddingH,
          vertical: 1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 1,
          children: [
            Icon(
              buttomItem.icon,
              size: _iconSize,
              color: isEndedAnimation & isSelected ? AppColors.primary200 : Colors.grey[700],
            ),
            SizedBox(
              width: 36,
              child: Text(
                buttomItem.label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isEndedAnimation & isSelected ? AppColors.primary200 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
