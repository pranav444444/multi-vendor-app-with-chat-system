

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class WithdrewEarningsScreen extends StatefulWidget {
  @override
  State<WithdrewEarningsScreen> createState() => _WithdrewEarningsScreenState();
}

class _WithdrewEarningsScreenState extends State<WithdrewEarningsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String bankName;

  late String accountName;

  late String accountNumber;

  late String  amount;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(
        title: Text('Withdrew Earnings'),
        iconTheme: IconThemeData(color: Colors.pink),
    ),
    body: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
         
          TextFormField(
            onChanged: (value){
              bankName = value;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please Enter Bank Name';
              }else{
                return null;
              }
            },
              decoration: InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter Bank Name',
                labelStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 5),
                hintStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
              ),
          ),

          SizedBox(height: 10,),

             TextFormField(
              
              onChanged: (value) {
                accountName = value;
              },  
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'Enter Account Name',
                labelStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 5),
                hintStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
              ),
          ),
            SizedBox(height: 10,),

             TextFormField(
              onChanged: (value) {
                accountNumber = value;
              },
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Enter Account Number',
                labelStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 5),
                hintStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
              ),
            ),

              TextFormField(
              onChanged: (value) {
                amount = value;
              },
              decoration: InputDecoration(
                labelText: 'Ammount',
                hintText: 'Enter Ammount',
                labelStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 5),
                hintStyle: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
              ),
            ),
           

           

            SizedBox(height: 25,),

            InkWell(
              onTap: ()async {
                DocumentSnapshot userDoc=await _firestore.collection('vendors').doc(_auth.currentUser!.uid).get();
                if (_formKey.currentState!.validate()) {
                  final withDrewId=Uuid().v4();
                  EasyLoading.show(status: 'Withdrew Earnings...');
                  await _firestore.collection('withdrewal').doc(withDrewId).set({
                    'businnessName':userDoc['businessName'],
                    'bankName':bankName,
                    'accountName':accountName,
                    'accountNumber':accountNumber,
                    'amount':amount,
                  }).whenComplete(() => EasyLoading.dismiss());
                 
                  }else {print('Error');}
                  
              },
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Get Cash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    ),
    ),
    );
  }
}