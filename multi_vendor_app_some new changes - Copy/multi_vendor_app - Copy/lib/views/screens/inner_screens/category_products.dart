import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/product_detail_screen.dart';

class CategoryProductScreen extends StatefulWidget {
  final dynamic categoryData;
  const CategoryProductScreen({super.key, required this.categoryData});

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.categoryData['categoryName'])
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryData['categoryName'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 200/300,
              ),
              itemBuilder: (context, index) {
                final productData = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productData: productData,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      splashColor: Colors.pink.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4, // Reduced image size slightly
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    productData['productImages'][0],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2, // Increased text area
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      productData['productName'],
                                      style: const TextStyle(
                                        fontSize: 13, // Slightly reduced font size
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1, // Reduced letter spacing
                                      ),
                                      maxLines: 2, // Increased to 2 lines
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2), // Added spacing
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '₹${productData['productPrice'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}