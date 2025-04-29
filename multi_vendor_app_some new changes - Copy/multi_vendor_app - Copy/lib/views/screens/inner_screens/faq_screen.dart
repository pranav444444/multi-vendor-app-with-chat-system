
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildFAQCard(
            'How do I place an order?',
            'Browse products, add items to cart, proceed to checkout, select payment method, and confirm your order.',
          ),
          _buildFAQCard(
            'What payment methods are accepted?',
            'We accept  cash on delivery.',
          ),
          
          _buildFAQCard(
            'What is the return policy?',
            'Products can be returned within 7 days of delivery if unused and in original packaging.',
          ),
          _buildFAQCard(
            'How do I contact customer support?',
            'You can reach us through chat support, email at support@chatterkart.com, or call us at 1800-123-4567.',
          ),
          _buildFAQCard(
            'Is my payment information secure?',
            'Yes, we use industry-standard encryption to protect your payment information.',
          ),
          
          _buildFAQCard(
            'How long does delivery take?',
            'It may depend on your location,but we will keep you updated on the delivery status through chat our phone.', 
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.pink[700],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.grey[50],
        textColor: Colors.pink[700],
        iconColor: Colors.pink[700],
      ),
    );
  }
}