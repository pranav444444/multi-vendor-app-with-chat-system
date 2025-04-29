import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:multi_vendor_app/controllers/categories__controller.dart';
import 'package:multi_vendor_app/views/screens/category_screen.dart';

class CategoryItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CategoryController _categoryController =
        Get.find<CategoryController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.pink[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            itemCount: _categoryController.categories.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemBuilder: (context, index) {
              return Column(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.18,
                  height: MediaQuery.of(context).size.width * 0.18,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.18 / 2),
                      border: Border.all(
                        color: Colors.grey,
                      )),
                  child: Image.network(
                    _categoryController.categories[index].categoryImage,
                  ),
                ),
                Text(
                  _categoryController.categories[index].categoryName
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]);
            },
          )
        ],
      );
    });
  }
}
