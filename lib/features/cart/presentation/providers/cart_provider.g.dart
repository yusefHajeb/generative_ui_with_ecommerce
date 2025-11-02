// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CartNotifier)
const cartProvider = CartNotifierProvider._();

final class CartNotifierProvider
    extends $AsyncNotifierProvider<CartNotifier, Cart> {
  const CartNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartNotifierHash();

  @$internal
  @override
  CartNotifier create() => CartNotifier();
}

String _$cartNotifierHash() => r'98ba7b38271df0017bf979e92eeb3f96941f2fa3';

abstract class _$CartNotifier extends $AsyncNotifier<Cart> {
  FutureOr<Cart> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Cart>, Cart>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Cart>, Cart>,
              AsyncValue<Cart>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed provider for cart total items count (for badge)

@ProviderFor(cartTotalItems)
const cartTotalItemsProvider = CartTotalItemsProvider._();

/// Computed provider for cart total items count (for badge)

final class CartTotalItemsProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Computed provider for cart total items count (for badge)
  const CartTotalItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalItemsHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartTotalItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartTotalItemsHash() => r'35a4f78a26653ea9e7897234cb7dc30471b77bac';

/// Computed provider for cart total price

@ProviderFor(cartTotalPrice)
const cartTotalPriceProvider = CartTotalPriceProvider._();

/// Computed provider for cart total price

final class CartTotalPriceProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Computed provider for cart total price
  const CartTotalPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalPriceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalPriceHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartTotalPrice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartTotalPriceHash() => r'8059f651d59878b366bd8581a8d10740d3375300';

/// Computed provider for cart items count

@ProviderFor(cartItemsCount)
const cartItemsCountProvider = CartItemsCountProvider._();

/// Computed provider for cart items count

final class CartItemsCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Computed provider for cart items count
  const CartItemsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartItemsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartItemsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartItemsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartItemsCountHash() => r'a051feb95633f8f8bcbf88bbfd9ac974d70e225f';

@ProviderFor(cartAddOperation)
const cartAddOperationProvider = CartAddOperationProvider._();

final class CartAddOperationProvider
    extends $FunctionalProvider<CartAdd, CartAdd, CartAdd>
    with $Provider<CartAdd> {
  const CartAddOperationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartAddOperationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartAddOperationHash();

  @$internal
  @override
  $ProviderElement<CartAdd> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartAdd create(Ref ref) {
    return cartAddOperation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartAdd>(value),
    );
  }
}

String _$cartAddOperationHash() => r'3d404767e40d03727c108d52b1396bb67443e41e';
