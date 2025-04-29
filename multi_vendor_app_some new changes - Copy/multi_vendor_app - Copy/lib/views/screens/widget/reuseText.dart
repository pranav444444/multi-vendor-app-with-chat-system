import 'package:flutter/material.dart';

class ReusetextWidget extends StatelessWidget {
  final String title;

  ReusetextWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
