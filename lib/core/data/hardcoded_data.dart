import 'package:generative_ui_with_ecommerce/features/products/data/models/product.dart';

class HardcodedData {
  static List<CartItem> cartItems = [
    CartItem(
      id: 1,
      item: Product(
        id: 102,
        title: 'Smart Watch',
        price: 199.99,
        description: 'Feature-rich smart watch with fitness tracking.',
        category: 'Wearables',
        image: 'https://example.com/images/smartwatch.png',
        rating: Rating(rate: 4.5, count: 150),
      ),
    ),
    CartItem(
      id: 2,
      item: Product(
        id: 103,
        title: 'Running Shoes',
        price: 89.99,
        description: 'Comfortable running shoes for all terrains.',
        category: 'Footwear',
        image: 'https://example.com/images/runningshoes.png',
        rating: Rating(rate: 4.2, count: 85),
      ),
    ),
  ];
}

class CartItem {
  final int id;
  final Product item;

  CartItem({required this.id, required this.item});
}
