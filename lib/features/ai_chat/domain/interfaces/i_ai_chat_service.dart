import 'package:generative_ui_with_ecommerce/features/ai_chat/data/models/ai_response.dart';

import '../../data/models/conversation_pair.dart';

abstract class IAiChatService {
  Future<AiResponse> processMessage(String message, List<ConversationPair> context);
}
