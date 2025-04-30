import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vendor_app_only/vendor/views/screens/vendorProductDetail/vendor_product_detail.dart';



class PublishedTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorProductStream = FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorProductStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.yellow.shade900,
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Published Products\nYet',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: ((context, index) {
                final vendorProductData = snapshot.data!.docs[index];
                return Slidable(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return VendorProductDetailScreen(productData: vendorProductData);
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              child: (() {
                                try {
                                  final productImages = vendorProductData.data() as Map<String, dynamic>;
                                  if (productImages.containsKey('productImages') && 
                                      productImages['productImages'] != null &&
                                      (productImages['productImages'] as List).isNotEmpty) {
                                    return Image.network(
                                      productImages['productImages'][0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    );
                                  }
                                } catch (e) {
                                  print('Error loading image: $e');
                                }
                                return const Icon(Icons.image_not_supported);
                              })(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (() {
                                      try {
                                        final data = vendorProductData.data() as Map<String, dynamic>;
                                        return data['productName']?.toString() ?? 'No Name';
                                      } catch (e) {
                                        return 'No Name';
                                      }
                                    })(),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    (() {
                                      try {
                                        final data = vendorProductData.data() as Map<String, dynamic>;
                                        return '₹ ${(data['productPrice'] ?? 0.0).toStringAsFixed(2)}';
                                      } catch (e) {
                                        return '₹ 0.00';
                                      }
                                    })(),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow.shade900
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    key: ValueKey(vendorProductData['productId']?.toString() ?? ''),
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (context) async {
                            await _firestore
                                .collection('products')
                                .doc(vendorProductData['productId'])
                                .delete();
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    )
                );
              }),
            ),
          );
        },
      ),
    );
  }
}