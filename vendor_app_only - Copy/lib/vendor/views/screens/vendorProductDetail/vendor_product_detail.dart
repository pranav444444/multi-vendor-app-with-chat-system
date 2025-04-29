import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const VendorProductDetailScreen({super.key, required this.productData});

  @override
  State<VendorProductDetailScreen> createState() =>
      _VendorProductDetailScreenState();
}

class _VendorProductDetailScreenState extends State<VendorProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.productData['productName'] ?? '';
    _brandNameController.text = widget.productData['brandName'] ?? '';
    _quantityController.text = widget.productData['productQuantity']?.toString() ?? '';
    _productPriceController.text = widget.productData['productPrice']?.toString() ?? '';
    _productDescriptionController.text = widget.productData['description'] ?? '';
    _categoryNameController.text = widget.productData['category'] ?? '';
  }

  double? productPrice;
  int? productQuantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade900,
        elevation: 0,
        title: Text(widget.productData['productName']),
      ),
      body: Form( // Wrap with Form widget
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                _productNameController, 
                'Product Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              _buildTextField(_brandNameController, 'Brand Name'),
              _buildNumberField(
                _quantityController, 
                'Quantity', 
                (value) {
                  productQuantity = int.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildNumberField(
                _productPriceController, 
                'Price', 
                (value) {
                  productPrice = double.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                maxLength: 800,
                maxLines: 3,
                controller: _productDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              TextFormField(
                enabled: false,
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade900,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () => _updateProduct(context),
          child: const Text(
            "UPDATE PRODUCT",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _firestore
          .collection('products')
          .doc(widget.productData['productId'])
          .update({
        'productName': _productNameController.text.trim(),
        'brandName': _brandNameController.text.trim(),
        'quantity': productQuantity,
        'productPrice': productPrice,
        'description': _productDescriptionController.text.trim(),
        'category': _categoryNameController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product Updated Successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context); // Return to previous screen after update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    Function(String) onChanged, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandNameController.dispose();
    _quantityController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }
}
