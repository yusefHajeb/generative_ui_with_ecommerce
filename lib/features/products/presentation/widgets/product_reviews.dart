import 'package:flutter/material.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/product_model.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/review_model.dart';
import 'package:generative_ui_with_ecommerce/core/utiles/animated_fade_scale.dart';

class ProductReviews extends StatelessWidget {
  final ProductModel product;

  const ProductReviews({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedFadeScale(
      duration: const Duration(milliseconds: 1000),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Reviews',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Review Summary - Simplified, remove rating distribution as it might not be important
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Average Rating
                    Column(
                      children: [
                        Text(
                          product.rating.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        StarRating(rating: product.rating),
                        Text(
                          '${product.reviews.length} reviews',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Reviews List - Show only 2 reviews instead of 3 to reduce clutter
              const SizedBox(height: 16),
              ...product.reviews.take(2).map((review) => _buildReviewItem(context, review)),

              if (product.reviews.length > 2)
                TextButton(
                  onPressed: () {
                    // Navigate to all reviews
                  },
                  child: Text(
                    'View All Reviews',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  review.reviewerName[0],
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    StarRating(rating: review.rating.toDouble()),
                  ],
                ),
              ),
              Text(
                _formatDate(review.date.toString()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.month}/${date.day}/${date.year}';
  }
}

// Star Rating Widget
class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
