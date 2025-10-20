// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppThemeMode)
const appThemeModeProvider = AppThemeModeProvider._();

final class AppThemeModeProvider
    extends $NotifierProvider<AppThemeMode, ThemeModeType> {
  const AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeModeType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeModeType>(value),
    );
  }
}

String _$appThemeModeHash() => r'b61b27dd4a85137110abfe339a69bc3269dce223';

abstract class _$AppThemeMode extends $Notifier<ThemeModeType> {
  ThemeModeType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeModeType, ThemeModeType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeModeType, ThemeModeType>,
              ThemeModeType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ThemeSeedColor)
const themeSeedColorProvider = ThemeSeedColorProvider._();

final class ThemeSeedColorProvider
    extends $NotifierProvider<ThemeSeedColor, Color> {
  const ThemeSeedColorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSeedColorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSeedColorHash();

  @$internal
  @override
  ThemeSeedColor create() => ThemeSeedColor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$themeSeedColorHash() => r'b27a173f110bb10769e1e3328356f7cf3ce54b29';

abstract class _$ThemeSeedColor extends $Notifier<Color> {
  Color build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Color, Color>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Color, Color>,
              Color,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
