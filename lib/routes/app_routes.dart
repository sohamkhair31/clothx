import 'package:flutter/material.dart';

// import '../screens/auth/login_screen.dart';
// import '../screens/auth/signup_screen.dart';
// import '../screens/home/home_screen.dart';
// import '../screens/cart/cart_screen.dart';
// import '../screens/orders/orders_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/product/product_screen.dart';
// import '../screens/checkout/checkout_screen.dart';
// import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = "/";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String home = "/home";
  static const String product = "/product";
  static const String cart = "/cart";
  static const String checkout = "/checkout";
  static const String orders = "/orders";
  static const String profile = "/profile";

  static Map<String, WidgetBuilder> routes = {
    // splash: (context) => const SplashScreen(),
    // login: (context) => const LoginScreen(),
    // signup: (context) => const SignupScreen(),
    // home: (context) => const HomeScreen(),
    // product: (context) => const ProductScreen(),
    // cart: (context) => const CartScreen(),
    // checkout: (context) => const CheckoutScreen(),
    // orders: (context) => const OrdersScreen(),
    // profile: (context) => const ProfileScreen(),
  };
}