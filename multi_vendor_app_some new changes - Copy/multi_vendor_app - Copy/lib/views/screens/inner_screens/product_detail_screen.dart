import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_vendor_app/provider/cart_provider.dart';
import 'package:multi_vendor_app/provider/selected_size_provider.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class ProductDetailScreen extends ConsumerStatefulWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, required this.productData});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;

  Future<String?> getVendorPhoneNumber(String vendorId) async {
    try {
      final vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      
      return vendorDoc.data()?['emailAddress'] as String?;
    } catch (e) {
      print('Error fetching vendor phone: $e');
      return null;
    }
  }

  void callvendor(String phoneNumber) async {
    // Remove any spaces or special characters if present
    phoneNumber = phoneNumber.trim();
    
    final Uri url = Uri.parse("tel:$phoneNumber");
    try {
      if (await launcher.canLaunchUrl(url)) {
        await launcher.launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showConfirmationDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Your Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Format the message
              String initialMessage = '''
🛒 New Order Request:
-------------------
Product: ${widget.productData['productName']}
Price: ₹${(widget.productData['productPrice'] ?? 0).toStringAsFixed(2)}

📦 Delivery Details:
Full Name: ${nameController.text}
Phone Number: ${phoneController.text}
Address: ${addressController.text}
''';

              // Add to cart
              final _cartProvider = ref.read(cartProvider.notifier);
              _cartProvider.addProductToCart(
                widget.productData['productName'],
                widget.productData['productId'],
                widget.productData['productImages'],
                1,
                widget.productData['productQuantity'],
                (widget.productData['productPrice'] ?? 0).toDouble(),
                widget.productData['vendorId'],
                ref.read(SelectedSizeProvider),
              );

              // Close dialog
              Navigator.pop(context);

              // Navigate to chat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    sellerId: widget.productData['vendorId'],
                    buyerId: FirebaseAuth.instance.currentUser!.uid,
                    productId: widget.productData['productId'],
                    productName: widget.productData['productName'],
                    initialMessage: initialMessage,
                  ),
                ),
              );
            },
            child: Text('Confirm', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }

  Stream<int> getUnreadMessageCount(String productId, String buyerId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('productId', isEqualTo: productId)
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: widget.productData['vendorId'])
        .where('seen', isEqualTo: false)
        .where('senderId', isEqualTo: widget.productData['vendorId'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> updateMessageSeenStatus(String productId, String buyerId) async {
    try {
      final QuerySnapshot messages = await FirebaseFirestore.instance
          .collection('chats')
          .where('productId', isEqualTo: productId)
          .where('buyerId', isEqualTo: buyerId)
          .where('sellerId', isEqualTo: widget.productData['vendorId'])
          .where('seen', isEqualTo: false)
          .where('senderId', isEqualTo: widget.productData['vendorId'])
          .get();

      final batch = FirebaseFirestore.instance.batch();
      
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'seen': true});
      }
      
      await batch.commit();
    } catch (e) {
      print('Error updating message seen status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSize = ref.watch(SelectedSizeProvider);
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartItem = ref.watch(cartProvider);
    final isInCart = cartItem.containsKey(widget.productData['productId']);

    // Get data safely with correct field names
    final String productName = widget.productData['productName'] ?? '';
    final double productPrice = (widget.productData['productPrice'] ?? 0).toDouble(); // Fixed issue
    final List<dynamic> productImages = widget.productData['productImages'] ?? [];
    final String description = widget.productData['description'] ?? '';
    final List<dynamic> sizeList = widget.productData['sizeList'] ?? [];
    final String storeImage = widget.productData['storeImage'] ?? '';
    final String businessName = widget.productData['businessName'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          productName,  // Changed from productname to productName
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 70), // Add padding for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            productImages[_imageIndex],  // Using local variable
                            fit: BoxFit.cover,
                          )),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productImages.length,
                          itemBuilder: (context, idex) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _imageIndex = idex;
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.pink,
                                  ),
                                  child: Image.network(productImages[idex]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName,  
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Color(0xff000000))),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.pink.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 16,
                              color: Colors.pink.shade400,
                            ),
                            SizedBox(width: 6),
                            Text(
                              widget.productData['brandName'] ?? 'Brand',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.pink.shade400,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '₹${productPrice.toStringAsFixed(2)}',  // Changed from \Rs to ₹
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Product Description',
                                style: TextStyle(color: Colors.pink)),
                            Text('View More', style: TextStyle(color: Colors.pink)),
                          ],
                        ),
                        children: [
                          Text(description,
                              style: TextStyle(fontSize: 16, letterSpacing: 2)),
                        ],
                      ),
                      SizedBox(height: 10),
                      ExpansionTile(
                        title: Text(
                          'VARIATION AVAILABLE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Container(
                            height: 50,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: sizeList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OutlinedButton(
                                        onPressed: () {
                                          final newSelected = sizeList[index];

                                          ref
                                              .read(SelectedSizeProvider.notifier)
                                              .selectedSize(newSelected);
                                        },
                                        child: Text(sizeList[index])),
                                  );
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(storeImage),
                        ),
                        title: Text(
                          businessName,
                          style:
                              TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('SELLER NAME',
                            style: TextStyle(
                                color: Colors.pink, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: isInCart
                        ? null
                        : () {
                            showConfirmationDialog();
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isInCart ? Colors.grey : Colors.pink.shade900,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.shopping_cart,
                              color: Colors.white,
                            ),
                            Text(
                              isInCart ? "IN CART" : "ADD TO CART",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 5),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () async {
                          // Update seen status
                          await updateMessageSeenStatus(
                            widget.productData['productId'],
                            FirebaseAuth.instance.currentUser!.uid,
                          );
                          
                          // Navigate to chat screen
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ChatScreen(
                              sellerId: widget.productData['vendorId'],
                              buyerId: FirebaseAuth.instance.currentUser!.uid,
                              productId: widget.productData['productId'],
                              productName: widget.productData['productName'],
                            );
                          }));
                        },
                        icon: Icon(CupertinoIcons.chat_bubble),
                        color: Colors.pink,
                      ),
                      StreamBuilder<int>(
                        stream: getUnreadMessageCount(
                          widget.productData['productId'],
                          FirebaseAuth.instance.currentUser!.uid,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == 0) {
                            return SizedBox.shrink();
                          }
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${snapshot.data}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      final vendorId = widget.productData['vendorId'];
                      final phoneNumber = await getVendorPhoneNumber(vendorId);
                      
                      if (phoneNumber != null) {
                        callvendor(phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not get vendor contact number'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(CupertinoIcons.phone),
                    color: Colors.pink,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




