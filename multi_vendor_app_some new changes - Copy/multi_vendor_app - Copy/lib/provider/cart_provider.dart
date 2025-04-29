import 'package:flutter/material.dart';
import 'package:multi_vendor_app/models/cart_models.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModel>>(
        (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, CartModel>> {
  CartNotifier() : super({});

  void addProductToCart(
    String productName,
    String productId,
    List imageUrl,
    int quantity,
    int productQuantity,
    double price,
    String vendorId,
    String productSize,
  ) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: CartModel(
          productName: productName,
          productId: productId,
          imageUrl: imageUrl,
          quantity: state[productId]!.quantity + 1,
          productQuantity: productQuantity,
          price: price,
          vendorId: vendorId,
          productSize: productSize,
        ),
      };
    } else {
      state = {
        ...state,
        productId: CartModel(
          productName: productName,
          productId: productId,
          imageUrl: imageUrl,
          quantity: quantity,
          productQuantity: productQuantity,
          price: price,
          vendorId: vendorId,
          productSize: productSize,
        ),
      };
    }
  }

  void incrementItem(String productId) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: CartModel(
          productName: state[productId]!.productName,
          productId: state[productId]!.productId,
          imageUrl: state[productId]!.imageUrl,
          quantity: state[productId]!.quantity + 1,
          productQuantity: state[productId]!.productQuantity,
          price: state[productId]!.price,
          vendorId: state[productId]!.vendorId,
          productSize: state[productId]!.productSize,
        ),
      };
    }
  }

  void decrementItem(String productId) {
    if (state.containsKey(productId) && state[productId]!.quantity > 1) {
      state = {
        ...state,
        productId: CartModel(
          productName: state[productId]!.productName,
          productId: state[productId]!.productId,
          imageUrl: state[productId]!.imageUrl,
          quantity: state[productId]!.quantity - 1,
          productQuantity: state[productId]!.productQuantity,
          price: state[productId]!.price,
          vendorId: state[productId]!.vendorId,
          productSize: state[productId]!.productSize,
        ),
      };
    } else if (state.containsKey(productId) && state[productId]!.quantity == 1) {
      removeItem(productId);
    }
  }

  void removeItem(String productId) {
    state.remove(productId);

    ///notify Listeners that the state has changed
    state = {...state};
  }

  void removeAllItems() {
    state.clear();

    ///notify Listeners that the state has changed
    state = {...state};
  }


  double calculateTotalAmount(){
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.price * cartItem.quantity;
    });

    
    return totalAmount;
  }
  Map<String, CartModel> get getCartItems => state;
}
