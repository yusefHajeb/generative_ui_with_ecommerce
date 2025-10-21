// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottom_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BottomNavigationIndex)
const bottomNavigationIndexProvider = BottomNavigationIndexProvider._();

final class BottomNavigationIndexProvider
    extends $NotifierProvider<BottomNavigationIndex, int> {
  const BottomNavigationIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomNavigationIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomNavigationIndexHash();

  @$internal
  @override
  BottomNavigationIndex create() => BottomNavigationIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bottomNavigationIndexHash() =>
    r'c5d1c7063034c085746b87a9c19a4ee3158bc53a';

abstract class _$BottomNavigationIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
