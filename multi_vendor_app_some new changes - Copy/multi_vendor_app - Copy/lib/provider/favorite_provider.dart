import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_vendor_app/models/favorite_models.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Map<String, FavoriteModel>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<Map<String, FavoriteModel>> {
  FavoriteNotifier() : super({});

  void addProductToFavorite(
    String productName,
    String productId,
    List imageUrl,
    int quantity,
    int productQuantity,
    double price,
    String vendorId,
  ) {
    state[productId] = FavoriteModel(
      productName: productName,
      productId: productId,
      imageUrl: imageUrl,
      quantity: quantity,
      productQuantity: productQuantity,
      price: price,
      vendorId: vendorId,
    );

    ///notify Listeners that the state has changed
    state = {...state};
  }

  void removeAllItems() {
    state.clear();

    ///notify Listeners that the state has changed
    state = {...state};
  }

  void removeItem(String productId) {
    state.remove(productId);

    ///notify Listeners that the state has changed
    state = {...state};
  }

  Map<String, FavoriteModel> get getFavoriteItems => state;
}
