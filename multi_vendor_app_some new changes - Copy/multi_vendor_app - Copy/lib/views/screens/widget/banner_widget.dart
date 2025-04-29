import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('banners').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Enhanced debug logging
        if (snapshot.hasData) {
          debugPrint('Number of documents: ${snapshot.data!.docs.length}');
          for (var doc in snapshot.data!.docs) {
            debugPrint('Document ID: ${doc.id}');
            final data = doc.data() as Map<String, dynamic>;
            debugPrint('Available fields: ${data.keys.toList()}');
            debugPrint('Full document data: $data');
          }
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No banners available'));
        }

        try {
          final List<String> bannerImages = [];
          
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Try multiple possible field names
            String? imageUrl;
            final possibleFields = ['imageUrl', 'image', 'url', 'banner_url'];
            
            for (var field in possibleFields) {
              if (data.containsKey(field)) {
                imageUrl = data[field] as String?;
                debugPrint('Found image URL in field: $field = $imageUrl');
                break;
              }
            }

            if (imageUrl != null && imageUrl.isNotEmpty) {
              bannerImages.add(imageUrl);
            } else {
              debugPrint('No valid image URL found in document ${doc.id}');
            }
          }

          if (bannerImages.isEmpty) {
            return const Center(
              child: Text('No valid banner images found'),
            );
          }

          return CarouselSlider.builder(
            itemCount: bannerImages.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: bannerImages[index], // Fixed: Using bannerImages[index] instead of e
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Image load failed', 
                            style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 180,
              viewportFraction: 0.8,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
            ),
          );
        } catch (e, stackTrace) {
          debugPrint('Error processing documents: $e');
          debugPrint('Stack trace: $stackTrace');
          return Center(child: Text('Error: $e'));
        }
      },
    );
  }
}
