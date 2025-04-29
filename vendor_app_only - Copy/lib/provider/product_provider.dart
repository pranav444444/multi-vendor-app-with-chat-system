import 'package:flutter/foundation.dart';

class ProductProvider extends ChangeNotifier {
  Map<String, dynamic> _productData = {};
  
  Map<String, dynamic> get getProductData => _productData;

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
    if (imageUrlList != null) _productData['imageUrlList'] = imageUrlList;
    if (productName != null) _productData['productName'] = productName;
    if (productPrice != null) _productData['productPrice'] = productPrice;
    if (quantity != null) _productData['quantity'] = quantity;
    if (category != null) _productData['category'] = category;
    if (description != null) _productData['description'] = description;
    if (chargeShipping != null) _productData['chargeShipping'] = chargeShipping;
    if (shippingCharge != null) _productData['shippingCharge'] = shippingCharge;
    if (sizeList != null) _productData['sizeList'] = sizeList;
    if (brandName != null) _productData['brandName'] = brandName;
    
    notifyListeners();
  }

  void clearData() {
    _productData = {};
    notifyListeners();
  }
}