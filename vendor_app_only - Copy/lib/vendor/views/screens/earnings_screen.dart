import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendor_app_only/vendor/views/screens/inner_screens/withdrew_earnings_screen.dart';

class EarningsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('vendors');
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(_auth.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic>? data;
          try {
            data = snapshot.data?.data() as Map<String, dynamic>?;
            if (data == null) {
              return const Center(child: Text('No data available'));
            }
          } catch (e) {
            return const Center(child: Text('Error loading data'));
          }

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(data['storeImage'] ?? ''),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Hi Welcome ${data['bussinessName'] ?? ''}",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _ordersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> orderSnapshot) {
                if (orderSnapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (orderSnapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                double totalOrder = 0.0;

                for (var orderItem in orderSnapshot.data!.docs) {
                  totalOrder += orderItem['quantity'] * orderItem['price'];
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade900,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Total Earnings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                            "\₹"  + totalOrder.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade900,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Total Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              orderSnapshot.data!.docs.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrewEarningsScreen()));
                        },
                        child: Container(height: 50, width: MediaQuery.of(context).size.width - 60, decoration: BoxDecoration(
                          color:Colors.pink.shade900,
                          borderRadius:BorderRadius.circular(9),
                        
                        
                        
                        ),
                        child:Center(
                        child: Text(
                          'Withdraw',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        ),
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          );
        }

        return CircularProgressIndicator();
      },
    );
  }
}
