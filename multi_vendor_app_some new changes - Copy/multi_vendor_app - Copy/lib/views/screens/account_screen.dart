import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/auth/login_screen.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/Customer_order_screen.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/edit_profile_screen.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/faq_screen.dart';
import 'package:multi_vendor_app/views/screens/cart_screen.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:get/get.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference buyers =
        FirebaseFirestore.instance.collection('buyers');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.sunny_snowing,
              color: Colors.pink,
            ),
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: buyers.doc(_auth.currentUser!.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 15),
                  CircleAvatar(
                    backgroundImage: NetworkImage(data['profileImage']),
                    radius: 65,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['fullName'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['email'],
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(context, 
                            MaterialPageRoute(builder: (context) {
                              return EditProfileScreen();
                            })
                          );
                          
                          if (result == true) {
                            // Force refresh the FutureBuilder
                            setState(() {});
                          }
                        },
                        child: Text('Edit Profile'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerOrderScreen(),
                        ),
                      );
                    },
                    leading: Icon(Icons.shopping_bag_outlined), // Changed from settings to shopping bag
                    title: Text(
                      'Orders',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      // Replace with your support phone number
                      _makePhoneCall('+91-1234567890'); 
                    },
                    leading: const Icon(Icons.phone),
                    title: const Text(
                      'Phone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                   
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    leading: Icon(CupertinoIcons.shopping_cart),
                    title: Text(
                      'Cart',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.help_outline),
                    title: const Text(
                      'FAQs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      await _auth.signOut().whenComplete(() {
                        return Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return CustomerLoginScreen();
                        }));
                      });
                    },
                    leading: Icon(Icons.logout),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    if (await launcher.canLaunchUrl(phoneUri)) {
      await launcher.launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}
