import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:generative_ui_with_ecommerce/core/extentions/app_extentions.dart';
import 'package:generative_ui_with_ecommerce/core/theme/app_color.dart';
import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/knowledge_model.dart';

import '../data/models/chat_message.dart';

class KnowledgeWidget extends ConsumerWidget {
  final ChatMessageData chatMessageData;
  const KnowledgeWidget({super.key, required this.chatMessageData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knowledgeData = chatMessageData.asKnowledge!;
    final topic = knowledgeData.title;
    if (knowledgeData.title == 'ShopAI Assistant') {
      return _buildAboutCard(context, knowledgeData);
    } else if (topic == 'What I Can Do') {
      return _buildCapabilitiesCard(context, knowledgeData);
    } else if (topic == 'How to Shop with Me') {
      return _buildHelpCard(context, knowledgeData);
    } else {
      return _buildGenericKnowledgeCard(context, knowledgeData);
    }
  }

  Widget _buildAboutCard(BuildContext context, KnowledgeData content) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.purple.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (content.tagline != null) ...[
                      const Gap(4),
                      Text(
                        content.tagline!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (content.description != null) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content.description!,
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard(BuildContext context, KnowledgeData knowledgeData) {
    final features = knowledgeData.features;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            knowledgeData.title,
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          if (features != null)
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(feature.icon, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Gap(4),
                          Text(
                            feature.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenericKnowledgeCard(BuildContext context, KnowledgeData knowledgeData) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            knowledgeData.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(12),

          if (knowledgeData.tips != null)
            ...(knowledgeData.tips)!
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

          if (knowledgeData.features != null)
            ...(knowledgeData.features)!.map(
              (e) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[400]?.withOpacity(0.3),
                  border: Border.all(color: Colors.grey[400]!, width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.name, style: TextStyle(fontSize: 14)),
                        Text(e.icon),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(e.description, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context, KnowledgeData knowledge) {
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
