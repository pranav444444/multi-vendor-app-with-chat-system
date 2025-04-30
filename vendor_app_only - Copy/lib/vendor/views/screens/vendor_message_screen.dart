import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor_app_only/vendor/views/screens/inner_screens/vendor_chat_detail.dart';

class VendorMessageScreen extends StatelessWidget {
  const VendorMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorChatStream = FirebaseFirestore.instance
        .collection('chats')
        .where(
          'sellerId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots();
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.yellow.shade900,
          title: Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _vendorChatStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No Messages Yet',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            Map<String, String> lastProductByBuyerId = {};
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                  Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
                  
                  String message = data['message'].toString();

                  String senderId = data['senderId'].toString();

                  String productId = data['productId'].toString();

                  /// Check if the message is from the seller
                  ///
                  bool isSellerMessage =
                      senderId == FirebaseAuth.instance.currentUser!.uid;

                  if (!isSellerMessage) {
                    String key = senderId + "_" + productId;
                    if (!lastProductByBuyerId.containsKey(key)) {
                      lastProductByBuyerId[key] = productId;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: GestureDetector(
                          onTap: () async {
                            // Mark message as seen before navigating
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(documentSnapshot.id)  // Use the document ID
                                .update({'seen': true});

                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return VendorChatDetail(
                                buyerId: data['buyerId'],
                                sellerId: FirebaseAuth.instance.currentUser!.uid,
                                productId: productId,
                                data: data,
                              );
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: NetworkImage(
                                        data['buyerPhoto'] ?? 'https://placeholder.com/user',
                                      ),
                                    ),
                                    // Replace the existing red dot with this larger notification badge
                                    if (data['timestamp'] != null &&
                                        (data['timestamp'] as Timestamp)
                                            .toDate()
                                            .isAfter(DateTime.now().subtract(Duration(hours: 24))) &&
                                        data['seen'] != true)  // Add this condition
                                      Positioned(
                                        right: -5,
                                        top: -5,
                                        child: Container(
                                          width: 22,  // Increased size
                                          height: 22, // Increased size
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'N',  // 'N' for New
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['buyerName'] ?? 'Customer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return SizedBox.shrink();
                });
          },
        ));
  }
}
