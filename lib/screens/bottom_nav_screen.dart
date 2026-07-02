import 'package:clothx/screens/cart/cart_screen.dart';
import 'package:clothx/screens/gender/men_screen.dart';
import 'package:clothx/screens/gender/women_screen.dart';
import 'package:clothx/screens/home/home_screen.dart';
import 'package:clothx/screens/orders/order_screen.dart';
import 'package:clothx/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() =>
      _BottomNavScreenState();
}

class _BottomNavScreenState
    extends State<BottomNavScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    MenScreen(),
    WomenScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.man),
            label: "Men",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.woman),
            label: "Women",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}