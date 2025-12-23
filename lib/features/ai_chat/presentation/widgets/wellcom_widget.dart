import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_in.dart';

class WellcomWidget extends StatelessWidget {
  const WellcomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final capabilities = [
      {
        'icon': '🛍️',
        'title': 'Find Products',
        'description': 'Search and discover amazing products from our catalog',
      },
      {
        'icon': '🛒',
        'title': 'Manage Cart',
        'description': 'Add items, update quantities, and checkout seamlessly',
      },
      {
        'icon': '💡',
        'title': 'Recommendations',
        'description': 'Receive personalized product suggestions based on your preferences',
      },
      {
        'icon': '📦',
        'title': 'Track Orders',
        'description': 'Check order status and delivery updates',
      },
      {
        'icon': '⭐',
        'title': 'Product Reviews',
        'description': 'Read and write reviews to help other shoppers',
      },
      {
        'icon': '🔍',
        'title': 'Smart Search',
        'description': 'Ask questions about products, categories, or shopping tips',
      },
    ];

    return AnimatedFadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary10.withOpacity(0.8),
              AppColors.primary50.withOpacity(0.6),
              AppColors.primary10.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary400.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppColors.primary300.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary10.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary500.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary500, size: 32),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How I Can Help You',
                        style: TextStyle(
                          color: AppColors.primary500,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Your AI shopping assistant is here!',
                        style: TextStyle(
                          color: AppColors.primary400,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Capabilities Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: capabilities.length,
              itemBuilder: (context, index) {
                final capability = capabilities[index];
                return AnimatedFadeIn(
                  duration: Duration(milliseconds: 300 + index * 100),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary200.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary400.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(capability['icon']!, style: const TextStyle(fontSize: 28)),
                          const Gap(8),
                          Text(
                            capability['title']!,
                            style: TextStyle(
                              color: AppColors.primary500,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(4),
                          Text(
                            capability['description']!,
                            style: TextStyle(
                              color: AppColors.primary400,
                              fontSize: 11,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const Gap(20),

            // Call to action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                // borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '💬 Start chatting!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
