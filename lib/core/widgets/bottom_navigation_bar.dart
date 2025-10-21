import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/provider/bottom_navigation_provider.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

class ButtomNavigationBar extends ConsumerStatefulWidget {
  const ButtomNavigationBar({super.key});

  @override
  ConsumerState<ButtomNavigationBar> createState() => _ButtomNavigationBarState();
}

class _ButtomNavigationBarState extends ConsumerState<ButtomNavigationBar> {
  final List<IconData> _icons = [
    Icons.home,
    Icons.shopping_basket_sharp,
    Icons.search,
    Icons.settings,
  ];

  // Design constants
  static const double _iconSize = 28.0;
  static const double _selectedPaddingH = 25.0;
  static const double _selectedPaddingV = 13.0;
  static const double _unselectedPaddingH = 20.0;
  static const double _unselectedPaddingV = 10.0;
  static const double _spaceBetween = 19.0;
  static const double _containerPadding = 6.0;
  static const double _borderRadius = 30.0;
  static const double _backgroundOpacity = 0.6;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  late bool isEndedAnimation;

  /// Calculates the width of an icon container based on selection state
  double _getIconWidth(bool isSelected) {
    return (isSelected ? _selectedPaddingH : _unselectedPaddingH) * 2 + _iconSize;
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
        color: (Colors.grey[200] ?? Colors.grey).withOpacity(_backgroundOpacity),
      ),
      child: Stack(
        children: [
          // Animated sliding background
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
                color: AppColors.primaryColor,
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
                  icon: _icons[index],
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
    required IconData icon,
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
          vertical: isSelected ? _selectedPaddingV : _unselectedPaddingV,
        ),
        child: Icon(
          icon,
          size: _iconSize,

          color: isEndedAnimation & isSelected ? AppColors.primary200 : Colors.grey[700],
        ),
      ),
    );
  }
}
