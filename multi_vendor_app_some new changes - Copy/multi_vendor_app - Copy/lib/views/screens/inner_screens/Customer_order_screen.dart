import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerOrderScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String formatedDate(Date) {
    final outPutDateFormat = DateFormat('dd-MM-yyyy');

    final outPutDate = outPutDateFormat.format(Date);

    return outPutDate;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('orderDate', descending: true)  // Sort by latest orders first
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No Orders Yet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Your order history will appear here'),
                ],
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: data['accepted'] == true
                          ? Icon(Icons.delivery_dining)
                          : Icon(Icons.access_time),
                    ),
                    title: data['accepted'] == true
                        ? Text(
                            "Accepted",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          )
                        : Text(
                            "Not Accepted",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                    trailing: Text(
                      "\₹" + data['price'].toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  ExpansionTile(
                      title: Text(
                        'Order Details',
                        style: TextStyle(color: Colors.pink.shade900),
                      ),
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Image.network(data['productImage'][0]),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['productName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Quantity',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data['quantity'].toString(),
                                    style: TextStyle(color: Colors.pink),
                                  ),
                                ],
                              )
                            ],
                          ),
                          subtitle: ListTile(
                            title: Text(
                              'Buyer Details',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.pink.shade900),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['fullName']),
                                Text(data['email']),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "order date: " +
                                        " " +
                                        formatedDate(
                                          data['orderDate'].toDate(),
                                        ),
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
