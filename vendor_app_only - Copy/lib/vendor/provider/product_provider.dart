import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier {
  Map<String, dynamic> productData = {};

  Map<String, dynamic> get getProductData => productData;

  void getFormData({
    List<String>? imageUrlList,
    String? productName,
    double? productPrice,
    int? quantity,
    String? category,
    String? description,
    bool? chargeShipping,
    double? shippingCharge,
    List<String>? sizeList,
    String? brandName,
  }) {
    if (imageUrlList != null) {
      productData['imageUrlList'] = imageUrlList;
      print('Updated imageUrlList: $imageUrlList');
    }
    if (productName != null) {
      productData['productName'] = productName;
      print('Updated productName: $productName');
    }
    if (productPrice != null) {
      productData['productPrice'] = productPrice;
      print('Updated productPrice: $productPrice');
    }
    if (quantity != null) {
      productData['quantity'] = quantity;
      print('Updated quantity: $quantity');
    }
    if (category != null) {
      productData['category'] = category;
      print('Updated category: $category');
    }
    if (description != null) {
      productData['description'] = description;
      print('Updated description: $description');
    }
    if (chargeShipping != null) {
      productData['chargeShipping'] = chargeShipping;
      print('Updated chargeShipping: $chargeShipping');
    }
    if (shippingCharge != null) {
      productData['shippingCharge'] = shippingCharge;
      print('Updated shippingCharge: $shippingCharge');
    }
    if (sizeList != null) {
      productData['sizeList'] = sizeList;
      print('Updated sizeList: $sizeList');
    }
    if (brandName != null) {
      productData['brandName'] = brandName;
      print('Updated brandName: $brandName');
    }

    notifyListeners();
  }

  void clearData() {
    productData.clear();
    notifyListeners();
  }
}
