import 'package:firebase_auth/firebase_auth.dart';
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

  void callvendor(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    try {
      if (await launcher.canLaunchUrl(url)) {
        await launcher.launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone call'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
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
      body: SingleChildScrollView(
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
                  Text(productName,  // Using local variable
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Color(0xff000000))),
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
      bottomSheet: BottomAppBar(
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
            IconButton(
              onPressed: () {
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
            IconButton(
              onPressed: () {
                callvendor(widget.productData['emailAddress']);
              },
              icon: Icon(CupertinoIcons.phone),
              color: Colors.pink,
            )
          ],
        ),
      ),
    );
  }
}
