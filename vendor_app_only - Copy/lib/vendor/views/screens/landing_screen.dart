import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendor_app_only/models/vendor_user_model.dart';
import 'package:vendor_app_only/vendor/views/auth/vendor_registration_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/main_vendor_screen.dart';
import 'package:vendor_app_only/vendor/views/screens/vendorMapScreen.dart';

class LandingScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference vendorStream = FirebaseFirestore.instance.collection('vendors');

    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: vendorStream.doc(_auth.currentUser!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if document exists - if not, navigate to registration
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return VendorRegistrationScreen();
          }

          try {
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
            
            if (data == null || data.isEmpty) {
              return VendorRegistrationScreen();
            }

            VendorUserModel vendorUserModel = VendorUserModel.fromJson(data);
            
            // Debug prints
            print("Document ID: ${snapshot.data!.id}");
            print("Approved status: ${vendorUserModel.approved}");
            print("Business name: ${vendorUserModel.buisnessName}");

            if (vendorUserModel.approved == true) {
              // Add debug print
              print("Navigating to MainVendorScreen");
              return MaterialApp(
                debugShowCheckedModeBanner: false,  // Add this line
                home: Scaffold(
                  body: MainVendorScreen(),
                ),
              );
            }
            
            // For unapproved vendors
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(vendorUserModel.storeImage,
                      width: 90,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(vendorUserModel.buisnessName ?? 'No Business Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text('Your Application, has been sent to shop admin\n admin will get back to you soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15,),
                  TextButton(onPressed: () async {await _auth.signOut();}, child: Text('Sign out',),),
                ],
              ),
            );
          } catch (e, stackTrace) {
            print("Error: $e");
            print("Stack trace: $stackTrace");
            return  VendorRegistrationScreen();
          }
        },
      ),
    );
  }
}
