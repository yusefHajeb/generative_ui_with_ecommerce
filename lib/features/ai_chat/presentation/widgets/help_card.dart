import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';

import '../../data/models/knowledge_model.dart';

class HelpCard extends StatelessWidget {
  final KnowledgeData knowledge;
  const HelpCard({super.key, required this.knowledge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.primary50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary400),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            knowledge.title,
            style: TextStyle(
              color: AppColors.primary500,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          if (knowledge.tips != null)
            ...(knowledge.tips)!
                .map(
                  (e) => Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey, width: 0.2),
                      ),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Text('💡'),
                        Flexible(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 91, 90, 90),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }
}
