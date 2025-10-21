import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/features/products/data/models/product.dart';
import 'package:generative_ui_with_ecommerce/features/products/data/repositories/products_repository.dart';

/// Async notifier for products
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  ProductsRepository? _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productsRepositoryProvider);
    return await _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final result = await _repository?.getProducts();
    return result?.fold((failure) => throw Exception(failure.message), (products) => products) ??
        [];
  }

  /// Refresh products
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchProducts);
  }

  /// Fetch products by category
  Future<void> fetchByCategory(String category) async {
    state = const AsyncValue.loading();
    final result = await _repository?.getProductsByCategory(category);
    state =
        result?.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          (products) => AsyncValue.data(products),
        ) ??
        AsyncValue.error('Unknown error', StackTrace.current);
  }
}

/// Products provider
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

/// Async notifier for categories
class CategoriesNotifier extends AsyncNotifier<List<String>> {
  ProductsRepository? _repository;

  @override
  Future<List<String>> build() async {
    _repository = ref.watch(productsRepositoryProvider);
    return await _fetchCategories();
  }

  Future<List<String>> _fetchCategories() async {
    final result = await _repository?.getCategories();
    return result?.fold(
          (failure) => throw Exception(failure.message),
          (categories) => categories,
        ) ??
        [];
  }

  /// Refresh categories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCategories);
  }
}

/// Categories provider
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<String>>(
  CategoriesNotifier.new,
);
