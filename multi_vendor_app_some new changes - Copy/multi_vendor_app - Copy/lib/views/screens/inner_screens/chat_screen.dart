import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String sellerId;
  final String buyerId;
  final String productId;
  final String productName;
  final String? initialMessage; // Add this

  const ChatScreen({
    Key? key,
    required this.sellerId,
    required this.buyerId,
    required this.productId,
    required this.productName,
    this.initialMessage, // Add this
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late Stream<QuerySnapshot> _chatStream;
  final Color _primaryColor = Colors.pink[600]!;
  final Color _lightPinkColor = Colors.pink[50]!;

  @override
  void initState() {
    super.initState();
    _chatStream = _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: widget.buyerId)
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('productId', isEqualTo: widget.productId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Add this check for initial message
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage(widget.initialMessage!);
      });
    }
  }

  void _sendInitialMessage(String message) async {
    DocumentSnapshot vendorDoc =
        await _firestore.collection('vendors').doc(widget.sellerId).get();

    DocumentSnapshot buyerDoc =
        await _firestore.collection('buyers').doc(widget.buyerId).get();

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
        'timestamp': DateTime.now(),
      });
    }
  }

  void _sendMessage() async {
    DocumentSnapshot vendorDoc =
        await _firestore.collection('vendors').doc(widget.sellerId).get();

    DocumentSnapshot buyerDoc =
        await _firestore.collection('buyers').doc(widget.buyerId).get();

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
        'timestamp': DateTime.now(),
      });
      setState(() {
        _messageController.clear();
      });
    }
  }

  String _formatMessageTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day) {
      // Today: show only time
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == yesterday.year && 
               dateTime.month == yesterday.month && 
               dateTime.day == yesterday.day) {
      // Yesterday: show 'Yesterday' and time
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      // Same year: show date without year and time
      return DateFormat('MMM d, HH:mm').format(dateTime);
    } else {
      // Different year: show full date and time
      return DateFormat('MMM d, yyyy HH:mm').format(dateTime);
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _lightPinkColor,
              child: Icon(Icons.shopping_bag, color: _primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    String senderId = data['senderId'];
                    bool isBuyerMessage = senderId == FirebaseAuth.instance.currentUser!.uid;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isBuyerMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isBuyerMessage) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(data['sellerPhoto']),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.65,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isBuyerMessage ? _primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomLeft: !isBuyerMessage ? const Radius.circular(5) : null,
                                bottomRight: isBuyerMessage ? const Radius.circular(5) : null,
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
                              crossAxisAlignment: isBuyerMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['message'],
                                  style: TextStyle(
                                    color: isBuyerMessage ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatMessageTimestamp(data['timestamp'] as Timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isBuyerMessage ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isBuyerMessage) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(data['buyerPhoto']),
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
                          fillColor: _lightPinkColor.withOpacity(0.3),
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
