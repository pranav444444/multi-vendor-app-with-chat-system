import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatedDate(Date) {
    final outPutDateFormat = DateFormat('dd-MM-yyyy');

    final outPutDate = outPutDateFormat.format(Date);

    return outPutDate;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          return Material(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Slidable(
                      key: ValueKey(data['orderId']),
                      child: Column(
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
                              "\u20B9${data['price'].toStringAsFixed(2)}",
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
                      ),
                      // Specify a key if the Slidable is dismissible.
                      // Removed duplicate key parameter

                      // The start action pane is the one at the left or the top side.
                      startActionPane: ActionPane(
                        // A motion is a widget used to control how the pane animates.
                        motion: const ScrollMotion(),

                        // A pane can dismiss the Slidable.
                        dismissible: DismissiblePane(onDismissed: () {}),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (context) async {
                              await _firestore
                                  .collection('orders')
                                  .doc(data['orderId'])
                                  .update({'accepted': false});
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Reject',
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              await _firestore
                                  .collection('orders')
                                  .doc(data['orderId'])
                                  .update({'accepted': true});
                            },
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.share,
                            label: 'Accept',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
