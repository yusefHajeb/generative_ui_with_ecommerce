import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generative_ui_with_ecommerce/core/widgets/chip_button.dart';
import 'package:generative_ui_with_ecommerce/features/products/presentation/providers/products_provider.dart';

// ignore: must_be_immutable
class CategoriesFilter extends StatelessWidget {
  WidgetRef ref;
  List<String> categories;
  CategoriesFilter({super.key, required this.categories, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 37,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1, // +1 for "All" category
          itemBuilder: (context, index) {
            final category = index == 0 ? 'All' : categories[index - 1];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ChipButton(
                onPressed: () {
                  if (category == 'All') {
                    ref.invalidate(productsProvider);
                  } else {
                    ref.read(productsProvider.notifier).fetchByCategory(category);
                  }
                },
                label: category,
              ),
            );
          },
        ),
      ),
    );
  }
}
