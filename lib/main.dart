import 'package:clothx/controllers/address_controller.dart';
import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/controllers/admin_order_controller.dart';
import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/cart_controller.dart';
import 'package:clothx/controllers/checkout_controller.dart';
import 'package:clothx/controllers/order_controller.dart';
import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/controllers/review_controller.dart';
import 'package:clothx/controllers/wishlist_controller.dart';
import 'package:clothx/core/services/cache/cache_service.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/firebase_options.dart';
import 'package:clothx/screens/auth/auth_screen.dart';
import 'package:clothx/screens/bottom_nav_screen.dart';
import 'package:clothx/screens/checkout/checkout_screen.dart';
import 'package:clothx/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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

  // Global Flutter Errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint("========== FLUTTER ERROR ==========");
    debugPrint(details.exceptionAsString());

    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };

  runApp(const ClothXApp());
}

class ClothXApp extends StatelessWidget {
  const ClothXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AddressController(),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistController(),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckoutController(),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductController()
            ..loadProductsFromCache()
            ..fetchProducts(),
        ),

        ChangeNotifierProvider(
          create: (_) => CartController()
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
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ClothX",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      routes: {
        "/home": (_) => const HomeScreen(),
        "/checkout": (_) => const CheckoutScreen(),
      },

      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          if (auth.isLoading && auth.currentUser == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (auth.currentUser == null) {
            return const AuthScreen();
          }

          return const BottomNavScreen();
        },
      ),
    );
  }
}