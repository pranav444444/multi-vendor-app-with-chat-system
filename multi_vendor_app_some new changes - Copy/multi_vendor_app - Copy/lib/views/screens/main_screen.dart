import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_vendor_app/views/screens/favorite_screen.dart';
import 'package:multi_vendor_app/views/screens/home_screen.dart';
import 'package:multi_vendor_app/views/screens/category_screen.dart';
import 'package:multi_vendor_app/views/screens/cart_screen.dart';
import 'package:multi_vendor_app/views/screens/Account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int pageindex = 0;

  List<Widget> _pages = [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    FavoriteScreen(),
    AccountScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              pageindex = value;
            });
          },
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.pink,
          currentIndex: pageindex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), // Changed to simple home icon
                activeIcon: Icon(Icons.home), // Added active icon state
                label: 'Home'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/explore.svg'),
                label: 'CATEGORIES'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/cart.svg'), 
                label: 'CART'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/favorite.svg'),
                label: 'FAVORITE'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/account.svg'),
                label: 'ACCOUNT'),
          ]),
      body: _pages[pageindex],
    );
  }
}
