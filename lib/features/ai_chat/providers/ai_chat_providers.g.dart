// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiChat)
const aiChatProvider = AiChatProvider._();

final class AiChatProvider
    extends $NotifierProvider<AiChat, List<ChatMessage>> {
  const AiChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiChatHash();

  @$internal
  @override
  AiChat create() => AiChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ChatMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChatMessage>>(value),
    );
  }
}

String _$aiChatHash() => r'd462c69879b24229f2ff54e82ff3175bcb8e67d1';

abstract class _$AiChat extends $Notifier<List<ChatMessage>> {
  List<ChatMessage> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<ChatMessage>, List<ChatMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ChatMessage>, List<ChatMessage>>,
              List<ChatMessage>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
