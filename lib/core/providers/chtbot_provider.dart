import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ChatState {
  final bool isChatVisible;
  final bool isFullScreen;
  final BoxConstraints constraints;

  const ChatState({
    this.isChatVisible = false,
    this.isFullScreen = false,
    this.constraints = const BoxConstraints(maxHeight: 760, maxWidth: double.infinity),
  });

  ChatState copyWith({bool? isChatVisible, bool? isFullScreen, BoxConstraints? constraints}) {
    return ChatState(
      isChatVisible: isChatVisible ?? this.isChatVisible,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      constraints: constraints ?? this.constraints,
    );
  }
}

// Chat state provider
final chatStateProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  // Show/hide chat
  void showChat() {
    state = state.copyWith(isChatVisible: true);
  }

  void hideChat() {
    state = state.copyWith(
      isChatVisible: false,
      isFullScreen: false, // Reset to default when hiding
      constraints: const BoxConstraints(maxHeight: 760, maxWidth: double.infinity),
    );
  }

  // Toggle fullscreen
  void toggleFullScreen() {
    final newFullScreen = !state.isFullScreen;
    final newConstraints = newFullScreen
        ? const BoxConstraints.expand()
        : const BoxConstraints(maxHeight: 760, maxWidth: double.infinity);

    state = state.copyWith(isFullScreen: newFullScreen, constraints: newConstraints);
  }

  // Update constraints directly
  void updateConstraints(BoxConstraints newConstraints) {
    state = state.copyWith(constraints: newConstraints);
  }
}
