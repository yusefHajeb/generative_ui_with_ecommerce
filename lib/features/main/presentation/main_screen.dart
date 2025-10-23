import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/providers/bottom_navigation_provider.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/bottom_navigation_bar.dart';
import 'package:generative_ui_with_ecommerce/features/home_page/presentation/home_screen.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/screens/products_screen.dart';
import 'package:generative_ui_with_ecommerce/features/search/presentation/screens/search_screen.dart';
import 'package:generative_ui_with_ecommerce/features/settings/presentation/screens/settings_screen.dart';

import '../../../core/widgets/liquid_glass_widget.dart' show LiquidGlassWidget;

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavigationIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBody(selectedIndex),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: LiquidGlassWidget(child: ButtomNavigationBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const ProductsScreen();
      case 1:
        return const HomeScreen();
      case 2:
        return const SearchScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}
