import 'package:generative_ui_with_ecommerce/core/routes/routes.dart';
import 'package:generative_ui_with_ecommerce/features/main/presentation/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/ai_chat/presentation/screens/ai_chat_screen_new.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.chatScreen,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const MainScreen()),
      GoRoute(path: AppRoutes.chatScreen, builder: (context, state) => const AiChatPage()),
    ],
  );
}
