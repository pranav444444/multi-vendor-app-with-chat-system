import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:multi_vendor_app/models/category_models.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<CategoryModels> categories = <CategoryModels>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCategories();
  }

  void _fetchCategories() {
    _firestore
        .collection('categories')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      categories.assignAll(
        querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return CategoryModels(
            categoryImage: data['Image'],
            categoryName: data['categoryName'],
          );
        }).toList(),
      );
    });
  }
}
