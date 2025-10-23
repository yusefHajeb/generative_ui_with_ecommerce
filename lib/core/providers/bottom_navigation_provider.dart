import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_navigation_provider.g.dart';

@riverpod
class BottomNavigationIndex extends _$BottomNavigationIndex {
  @override
  int build() {
    // Default to home tab (index 0)
    return 0;
  }

  void setIndex(int index) {
    if (index >= 0 && index <= 3) {
      state = index;
    }
  }

  /// Checks if the given index is currently selected.
  bool isSelected(int index) {
    return state == index;
  }
}

/// Enum representing the navigation items in the bottom navigation bar.
enum NavigationItem {
  home('Home'),
  basket('Shopping Basket'),
  search('Search'),
  settings('Settings');

  const NavigationItem(this.label);

  final String label;
}
