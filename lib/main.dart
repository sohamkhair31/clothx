import 'package:clothx/screens/bottom_nav_screen.dart';
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

  // Hive init
  await Hive.initFlutter();

  final cacheService = CacheService();
  await cacheService.init();

  // Firebase init
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ProductController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              CartController()
                ..loadCart(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              OrderController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              AdminController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              AdminOrderController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ReviewController(),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ClothX",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const BottomNavScreen(),
    );
  }
}