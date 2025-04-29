import 'package:flutter_riverpod/flutter_riverpod.dart';

final SelectedSizeProvider =
    StateNotifierProvider<SelectedSizeNotifieer, String>((ref) {
  return SelectedSizeNotifieer();
});

class SelectedSizeNotifieer extends StateNotifier<String> {
  SelectedSizeNotifieer() : super("");

  void selectedSize(String size) {
    state = size;
  }
}
