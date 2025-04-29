import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vendor_app_only/vendor/views/screens/tab-bar_screens/attributes_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/tab-bar_screens/general_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/tab-bar_screens/images_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/tab-bar_screens/shipping_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/main_vendor_screen.dart';
import 'package:vendor_app_only/vendor/provider/product_provider.dart';

class UploadScreen extends StatefulWidget {
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4, // Update length to match your tabs
      vsync: this,
    );
    _tabController.addListener(() {
      // This ensures form validation before tab change
      if (_tabController.indexIsChanging) {
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade900,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text('General')),
              Tab(child: Text('Shipping')),
              Tab(child: Text('Attribute')),
              Tab(child: Text('Images')),
              
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            GeneralScreen(),
            ShippingScreen(),
            AttributesScreen(),
            ImagesScreen(),
            Container(), // Add your VideoScreen here
          ],
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade900,
            ),
            onPressed: () async {
              try {
                if (productProvider.productData.isEmpty) {
                  EasyLoading.showError('Product data is missing');
                  return;
                }

                // Add validation for required fields
                final requiredFields = {
                  'productName': 'Product Name',
                  'brandName': 'Brand Name',
                  'category': 'Category',
                  'description': 'Description',
                  'productPrice': 'Product Price',
                  'quantity': 'Quantity',
                };

                for (var entry in requiredFields.entries) {
                  if (productProvider.productData[entry.key] == null || 
                      productProvider.productData[entry.key].toString().isEmpty) {
                    EasyLoading.showError('${entry.value} is required');
                    return;
                  }
                }

                if (_formKey.currentState!.validate()) {
                  EasyLoading.show(status: 'Please Wait...');
                  
                  final productId = Uuid().v4();
                  final userDoc = await _firestore
                      .collection('vendors')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();
                  
                  if (!userDoc.exists) {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vendor profile not found')),
                    );
                    return;
                  }

                  final userData = userDoc.data() as Map<String, dynamic>;
                  
                  print('User Data: $userData');
                  print('Product Data: ${productProvider.productData}');

                  await _firestore.collection('products').doc(productId).set({
                    'productId': productId,
                    'vendorId': FirebaseAuth.instance.currentUser!.uid,
                    
                    // Business Details
                    'businessName': userData['businessName'] ?? '', // Fixed typo here
                    'storeImage': userData['storeImage'] ?? '',
                    'countryValue': userData['countryValue'] ?? '',
                    'stateValue': userData['stateValue'] ?? '',
                    'cityValue': userData['cityValue'] ?? '',
                    
                    // Product Details
                    'productName': productProvider.productData['productName'] ?? '',
                    'brandName': productProvider.productData['brandName'] ?? '',
                    'category': productProvider.productData['category'] ?? '',
                    'description': productProvider.productData['description'] ?? '',
                    
                    // Price and Quantity
                    'productPrice': productProvider.productData['productPrice'] ?? 0.0,
                    'productQuantity': productProvider.productData['quantity'] ?? 0,
                    
                    // Shipping Details
                    'chargeShipping': productProvider.productData['chargeShipping'] ?? false,
                    'shippingCostFee': productProvider.productData['shippingCharge'] ?? 0.0,
                    
                    // Images and Size
                    'productImages': productProvider.productData['imageUrlList'] ?? [],
                    'sizeList': productProvider.productData['sizeList'] ?? null,
                  }).whenComplete(() async {  // Changed to async
                    productProvider.clearData();
                    _formKey.currentState!.reset();
                    EasyLoading.dismiss();
                    
                    // Show success message with await
                    await ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,  // Center the content
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Product uploaded successfully!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),  // Increased duration
                        behavior: SnackBarBehavior.floating,  // Makes it float above bottom sheet
                        margin: EdgeInsets.all(10),  // Adds margin around the snackbar
                        elevation: 6,  // Adds shadow
                      ),
                    );
                    
                    // Wait before navigation
                    await Future.delayed(Duration(seconds: 3));
                    
                    if (mounted) {  // Check if widget is still mounted
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainVendorScreen()),
                      );
                    }
                  });
                }
              } catch (e) {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Failed to upload product: ${e.toString()}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ),
      ),
    );
  }
}