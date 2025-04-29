import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_only/vendor/provider/product_provider.dart';

class GeneralScreen extends StatefulWidget {
  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _categoryList = [];
  String? _selectedCategory;

  Future<void> _getCategories() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('categories').get();
      setState(() {
        _categoryList.clear();
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          // Get the categoryName field specifically
          if (data.containsKey('categoryName')) {
            _categoryList.add(data['categoryName'] as String);
          }
        }
      });
      print('Categories loaded: $_categoryList'); // Debug print
    } catch (e, stackTrace) {
      print('Error loading categories: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      body: Form(
        key: _formKey, // Use the GlobalKey to manage the form state
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    productProvider.getFormData(productName: value);
                    print('Product Name updated: $value'); // Debug print
                  },
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                // Price field
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product price';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    productProvider.getFormData(
                      productPrice: double.tryParse(value) ?? 0.0
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Product Price',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                // Quantity field
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    productProvider.getFormData(
                      quantity: int.tryParse(value) ?? 0
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Product Quantity',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    productProvider.getFormData(category: value);
                  },
                  hint: Text('Select Category', 
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 4
                    )
                  ),
                  isExpanded: true,  // Add this to prevent overflow
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),  // Add border for better visibility
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  items: _categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),

                SizedBox(height: 5,),

                TextFormField(
                  maxLines: 10,
                  minLines: 3,
                  maxLength: 800,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product description';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    productProvider.getFormData(description: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Product Description',
                    hintText: 'Enter Product Description',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}