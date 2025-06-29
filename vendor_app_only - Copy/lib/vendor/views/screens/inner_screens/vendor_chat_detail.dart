import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VendorChatDetail extends StatefulWidget {
  final String buyerId;
  final String sellerId;
  final String productId;
  final dynamic data;

  const VendorChatDetail({
    super.key,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    this.data,
  });

  @override
  State<VendorChatDetail> createState() => _VendorChatDetailState();
}

class _VendorChatDetailState extends State<VendorChatDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late Stream<QuerySnapshot> _chatStream;
  final Color _primaryColor = Colors.yellow.shade900;
  final Color _lightColor = Colors.yellow.shade50;

  @override
  void initState() {
    super.initState();
    updateExistingMessages(); // Add this line
    _chatStream = _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: widget.buyerId)
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('productId', isEqualTo: widget.productId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatMessageTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day) {
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == yesterday.year && 
               dateTime.month == yesterday.month && 
               dateTime.day == yesterday.day) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy HH:mm').format(dateTime);
    }
  }

  void _sendMessage() async {
    DocumentSnapshot vendorDoc = await _firestore.collection('vendors').doc(widget.sellerId).get();
    DocumentSnapshot buyerDoc = await _firestore.collection('buyers').doc(widget.buyerId).get();
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      await _firestore.collection('chats').add({
        'productId': widget.productId,
        'buyerName': (buyerDoc.data() as Map<String, dynamic>)['fullName'],
        'buyerPhoto': (buyerDoc.data() as Map<String, dynamic>)['profileImage'],
        'sellerPhoto': (vendorDoc.data() as Map<String, dynamic>)['storeImage'],
        'buyerId': widget.buyerId,
        'sellerId': widget.sellerId,
        'message': message,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false  // Add this field
      });
      
      setState(() {
        _messageController.clear();
      });
    }
  }

  Future<void> updateExistingMessages() async {
    try {
      // Get all chat messages without a seen field or all messages
      QuerySnapshot chatDocs = await FirebaseFirestore.instance
          .collection('chats')
          .get();  // Remove the where clause to get all documents

      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (var doc in chatDocs.docs) {
        // Add seen field if it doesn't exist
        if (!(doc.data() as Map<String, dynamic>).containsKey('seen')) {
          batch.update(doc.reference, {
            'seen': false,
          });
        }
      }

      await batch.commit();
      print('Successfully updated ${chatDocs.docs.length} messages');
    } catch (e) {
      print('Error updating messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat with Customer',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    String senderId = data['senderId'];
                    bool isSellerMessage = senderId == FirebaseAuth.instance.currentUser!.uid;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isSellerMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isSellerMessage) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(data['buyerPhoto']),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.65,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSellerMessage ? _primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomLeft: !isSellerMessage ? const Radius.circular(5) : null,
                                bottomRight: isSellerMessage ? const Radius.circular(5) : null,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isSellerMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['message'],
                                  style: TextStyle(
                                    color: isSellerMessage ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatMessageTimestamp(data['timestamp'] as Timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSellerMessage ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSellerMessage) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(data['sellerPhoto']),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: _lightColor.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        cursorColor: _primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
