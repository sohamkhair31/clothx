import 'package:clothx/controllers/address_controller.dart';
import 'package:clothx/controllers/checkout_controller.dart';
import 'package:clothx/screens/admin/admin_dashboard_screen.dart';
import 'package:clothx/screens/auth/auth_screen.dart';
import 'package:clothx/screens/bottom_nav_screen.dart';
import 'package:clothx/screens/checkout/checkout_screen.dart';
import 'package:clothx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/services/cache/cache_service.dart';

import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/admin_order_controller.dart';
import 'controllers/review_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();

  final cacheService = CacheService();
  await cacheService.init();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
  create: (_) => AddressController(),
),
        ChangeNotifierProvider(
  create: (_) => CheckoutController(),
),
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ProductController()
                ..loadProductsFromCache(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              CartController()
                ..loadCart(),
        ),

        ChangeNotifierProvider(
          create: (_) => OrderController(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminController(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminOrderController(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReviewController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
    "/checkout": (_) => const CheckoutScreen(),
    "/home": (_) => const HomeScreen(),
  },
      title: "ClothX",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthController>(
  builder: (context, auth, _) {
    // Loading
    if (auth.isLoading &&
        auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not Logged In
    if (auth.currentUser == null) {
      return const AuthScreen();
    }

    // Logged In
    return const BottomNavScreen();
  },
),
   
    );
  }
}