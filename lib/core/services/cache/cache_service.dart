import 'package:hive/hive.dart';

class CacheService {
  // Singleton instance
  static final CacheService _instance =
      CacheService._internal();

  factory CacheService() => _instance;

  CacheService._internal();

  static const String productBoxName = "products";
  static const String cartBoxName = "cart";
  static const String userBoxName = "user";

  late Box productBox;
  late Box cartBox;
  late Box userBox;

  Future<void> init() async {
    productBox = await Hive.openBox(productBoxName);
    cartBox = await Hive.openBox(cartBoxName);
    userBox = await Hive.openBox(userBoxName);
  }

  // ---------------- PRODUCT CACHE ----------------

  Future<void> saveProducts(
    List<Map<String, dynamic>> products,
  ) async {
    await productBox.put("product_list", products);
  }

  List getProducts() {
    return productBox.get(
      "product_list",
      defaultValue: [],
    );
  }

  Future<void> clearProducts() async {
    await productBox.delete("product_list");
  }

  // ---------------- CART CACHE ----------------

  Future<void> saveCart(
    List<Map<String, dynamic>> cartItems,
  ) async {
    await cartBox.put("cart_items", cartItems);
  }

  List getCart() {
    return cartBox.get(
      "cart_items",
      defaultValue: [],
    );
  }

  Future<void> clearCart() async {
    await cartBox.delete("cart_items");
  }

  // ---------------- USER CACHE ----------------

  Future<void> saveUser(
    Map<String, dynamic> userData,
  ) async {
    await userBox.put("user_data", userData);
  }

  Map<String, dynamic>? getUser() {
    final data = userBox.get("user_data");

    if (data == null) return null;

    return Map<String, dynamic>.from(data);
  }

  Future<void> clearUser() async {
    await userBox.delete("user_data");
  }

  // ---------------- FULL CLEAR ----------------

  Future<void> clearAll() async {
    await productBox.clear();
    await cartBox.clear();
    await userBox.clear();
  }

  Future<void> saveLastMeta(String value) async {
  await productBox.put("last_meta", value);
}

String? getLastMeta() {
  return productBox.get("last_meta");
}
}