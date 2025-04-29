import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_vendor_app/provider/favorite_provider.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/product_detail_screen.dart';

class ProductModel extends ConsumerWidget {
  const ProductModel({
    super.key,
    required this.productData,
  });

  final QueryDocumentSnapshot<Object?> productData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _favProvider = ref.read(favoriteProvider.notifier);
    ref.watch(favoriteProvider);
    
    final data = productData.data() as Map<String, dynamic>;
    
    return InkWell(  // Changed from GestureDetector to InkWell for better feedback
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productData: productData,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: const Color(0xffffffff),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0f000000),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        (data['productImages'] as List).first.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          data['productName']?.toString() ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '\u20B9${(data['productPrice']?.toString() ?? '0.00')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 15,
            child: IconButton(
              onPressed: () {
                _favProvider.addProductToFavorite(
                  data['productName'] ?? '',
                  data['productId'] ?? '',
                  data['productImages'] ?? [],
                  1,
                  data['productQuantity'] ?? 0,
                  data['productPrice']?.toDouble() ?? 0.0,
                  data['vendorId'] ?? '',
                );
              },
              icon: _favProvider.getFavoriteItems.containsKey(data['productId'])
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite_border, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
