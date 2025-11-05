import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/constants/constantnts.dart';
import 'package:generative_ui_with_ecommerce/core/providers/bottom_navigation_provider.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/bottom_navigation_bar.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/presentation/widgets/dynamic_chat_widget.dart'
    show DynamicChatWidget;
import 'package:generative_ui_with_ecommerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:generative_ui_with_ecommerce/features/home_page/presentation/home_screen.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/screens/products_screen.dart';
import 'package:generative_ui_with_ecommerce/features/search/presentation/screens/search_screen.dart';

import '../../../core/widgets/liquid_glass_widget.dart' show LiquidGlassWidget;
import '../../ai_chat/presentation/screens/ai_chat_screen_new.dart';

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
          // Floating Action Button for AI Chat
          if (selectedIndex != 1) // Hide FAB when on AI Chat tab
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _showChatBottomSheet(context),
                backgroundColor: AppColors.primary500,
                tooltip: 'Chat with AI Assistant',
                child: Image.asset(Constantnts.iaChatIcon, width: 50),
              ),
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
        return const AiChatPage();
      case 2:
        return const SearchScreen();
      case 3:
        return const CartScreen();
      default:
        return const HomeScreen();
    }
  }

  void _showChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: 760, maxWidth: double.infinity),
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicChatWidget(
        isFullScreen: false,
        onClose: () => log('object'),
        onToggleFullScreen: () => log('onLogTogel'),
      ),
    );
  }
}
