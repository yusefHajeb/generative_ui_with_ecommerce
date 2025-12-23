import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/core/routes/routes.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/core/routes/dialog_go_route.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/widgets/dialog_route_container.dart';
import 'package:generative_ui_with_ecommerce/features/main/presentation/main_screen.dart';
import 'package:generative_ui_with_ecommerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/screens/product_details_screen.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/screens/products_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const MainScreen()),
      GoRoute(path: AppRoutes.cart, builder: (context, state) => const CartScreen()),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      ),
      DialogGoRoute(
        path: '/dialoge-test',
        builder: (context, state) =>
            DialogRouteContainer(isTransaction: true, height: 800, widget: CartScreen()),
      ),
      GoRoute(path: AppRoutes.products, builder: (context, state) => ProductsScreen()),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) =>
            Scaffold(body: Center(child: Text('this page will be add soon'))),
      ),
    ],
  );
}
