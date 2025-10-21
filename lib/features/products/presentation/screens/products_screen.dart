import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_in.dart';
import 'package:generative_ui_with_ecommerce/features/products/data/models/product.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/providers/products_provider.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/categories_filter.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/widgets/product_card.dart';

import '../../../../core/widgets/base_provider_widget.dart';
import '../widgets/error_widget.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: Column(
          children: [
            // Categories Filter
            BaseStateWidget<List<String>>(
              builder: (context, categories) => CategoriesFilter(ref: ref, categories: categories),
              provider: categoriesAsync,
              fakeData: ['all', 'man', 'dfadadf', 'dadfdada'],
            ),
            Expanded(
              child: BaseStateWidget<List<Product>>(
                builder: (context, products) => _buildProductsGrid(products),
                provider: productsAsync,
                errorWidget: (error, stack) => ErrorProviderWidget(
                  error: error,
                  stack: stack,
                  onPressed: () {
                    ref.invalidate(productsProvider);
                  },
                ),
                fakeData: [
                  for (int i = 0; i < 10; i++)
                    Product(
                      id: 2,
                      title: 'title',
                      price: 33,
                      description: 'description',
                      category: 'category',
                      image: 'image',
                      rating: Rating(rate: 43, count: 343),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 6,
        mainAxisSpacing: 2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return AnimatedFadeIn(
          duration: Duration(milliseconds: index * 50),
          child: ProductCard(
            product: product,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Tapped on ${product.title}')));
            },
          ),
        );
      },
    );
  }
}
