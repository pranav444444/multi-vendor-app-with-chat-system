import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/inner_screens/checkout_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isPayOnDelivery = false;  // Move boolean here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Options',
          style: TextStyle(fontWeight: FontWeight.w400,
          letterSpacing: 4),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.black87,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pay on Delivery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Switch(
                  value: isPayOnDelivery,
                  onChanged: (value) {
                    setState(() {
                      isPayOnDelivery = value;
                    });

                    if(isPayOnDelivery){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const CheckoutScreen()));
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}