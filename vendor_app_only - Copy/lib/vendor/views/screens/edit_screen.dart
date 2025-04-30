import 'package:flutter/material.dart';
import 'package:vendor_app_only/vendor/views/screens/edit_products_tab/published_tab.dart';
import 'package:vendor_app_only/vendor/views/screens/edit_products_tab/unpublished_tab.dart';



class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.yellow.shade900,
          title: Text(
            'Manage Products',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(tabs: [
            Tab(
              child: Text('Published'),
            ),
            Tab(
              child: Text('Unpublished'),
            ),
          ]),
        ),
        body: TabBarView(children: [
          PublishedTab(),
          UnPublishedTab(),
        ]),
      ),
    );
  }
}