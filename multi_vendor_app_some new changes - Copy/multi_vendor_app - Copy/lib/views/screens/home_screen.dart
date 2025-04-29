import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/widget/banner_widget.dart';
import 'package:multi_vendor_app/views/screens/widget/category_text_widget.dart';
import 'package:multi_vendor_app/views/screens/widget/home_products.dart';
import 'package:multi_vendor_app/views/screens/widget/location_widget.dart';
import 'package:multi_vendor_app/views/screens/widget/reuseText.dart';
import 'package:multi_vendor_app/views/screens/widget/men_product_widget.dart';
import 'package:multi_vendor_app/views/screens/widget/women_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocationWidget(),
          BannerWidget(),
          CategoryItemWidget(),
          HomeProductWidget(),
          // Description section with reduced top spacing
          Container(
            padding: const EdgeInsets.only(
              left: 16, 
              right: 16,
              top: 5, // Reduced from 10
              bottom: 10
            ),
            margin: const EdgeInsets.only(top: 0), // Added margin control
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why Choose ChatterKart?', // Changed text to be more engaging
                  style: TextStyle(
                    fontSize: 20, // Slightly reduced size
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 12
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_bag, color: Colors.pink[400]),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Your One-Stop Shopping Destination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Discover a wide range of products from trusted sellers. Shop with confidence and enjoy secure transactions, fast delivery, and excellent customer service.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
