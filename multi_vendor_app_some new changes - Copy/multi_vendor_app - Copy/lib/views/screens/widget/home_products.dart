import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/widget/product_model.dart';

class HomeProductWidget extends StatelessWidget {
  const HomeProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream =
        FirebaseFirestore.instance.collection('products').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _productStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SizedBox(
          height: 250, // Increased height for better visibility
          child: PageView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              
              // Debug print to check actual field names
              print('Document fields: ${productData.data() as Map<String, dynamic>}');
              
              return ProductModel(productData: productData);
            },
          ),
        );
      },
    );
  }
}
