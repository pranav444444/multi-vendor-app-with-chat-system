import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_vendor_app/provider/cart_provider.dart';

import 'package:multi_vendor_app/views/screens/inner_screens/payment_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartData = ref.watch(cartProvider);
    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 5),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _cartProvider.removeAllItems();
            },
            icon: Icon(CupertinoIcons.delete),
          )
        ],
      ),
      body: cartData.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: cartData.length,
              itemBuilder: (context, index) {
                final cartItem = cartData.values.toList()[index];

                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.network(
                              cartItem.imageUrl[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.productName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '\u20B9${cartItem.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                _cartProvider.decrementItem(
                                                    cartItem.productId);
                                              },
                                              icon: Icon(
                                                CupertinoIcons.minus,
                                                color: Colors.white,
                                              )),
                                          Text(
                                            cartItem.quantity.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                _cartProvider.incrementItem(
                                                    cartItem.productId);
                                              },
                                              icon: Icon(
                                                CupertinoIcons.plus,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _cartProvider.removeItem(cartItem.productId);
                                      },
                                      icon: Icon(CupertinoIcons.delete),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )));
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5),
                  ),
                  Text(
                    "You haven't added any items to your Cart yet\n you can add from the home screen",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5,
                        color: Colors.grey),
                  )
                ],
              ),
            ),

      bottomNavigationBar: cartData.isNotEmpty 
        ? Container(
          height: 80, // Added fixed height
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Added Expanded
                flex: 2, // Gives more space to price
                child: Text(
                  'Total Price \u20B9${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16, // Reduced font size
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2 // Reduced letter spacing
                  ),
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                ),
              ),
              const SizedBox(width: 10), // Added spacing
              Expanded( // Added Expanded
                flex: 1, // Gives less space to button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if(cartData.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const PaymentScreen();  // Make sure to keep const
                      }));
                    }
                  }, 
                  child: const FittedBox( // Added FittedBox
                    child: Text(
                      'CHECKOUT',
                      style: TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ),
              )
            ],
          ),
        )
        : const SizedBox.shrink(),
    );
  }
}
