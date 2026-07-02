import 'package:hive/hive.dart';

class CacheService {
  static final CacheService _instance =
      CacheService._internal();

  factory CacheService() => _instance;

  CacheService._internal();

  static const String productBoxName = "products";
  static const String cartBoxName = "cart";
  static const String userBoxName = "user";
  static const String orderBoxName = "orders";

  late Box productBox;
  late Box cartBox;
  late Box userBox;
  late Box orderBox;

  Future<void> init() async {
    productBox = await Hive.openBox(productBoxName);
    cartBox = await Hive.openBox(cartBoxName);
    userBox = await Hive.openBox(userBoxName);
    orderBox = await Hive.openBox(orderBoxName);
  }

  // ================= PRODUCTS =================

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

  Future<void> saveLastMeta(String value) async {
    await productBox.put("last_meta", value);
  }

  String? getLastMeta() {
    return productBox.get("last_meta");
  }

  // ================= REVIEWS =================

  Future<void> saveReviews(
    String productId,
    List<Map<String, dynamic>> reviews,
  ) async {
    await productBox.put(
      "reviews_$productId",
      reviews,
    );
  }

  List getReviews(String productId) {
    return productBox.get(
      "reviews_$productId",
      defaultValue: [],
    );
  }

  Future<void> saveReviewMeta(
    String productId,
    String meta,
  ) async {
    await productBox.put(
      "review_meta_$productId",
      meta,
    );
  }

  String? getReviewMeta(String productId) {
    return productBox.get(
      "review_meta_$productId",
    );
  }

  Future<void> clearReviews(String productId) async {
    await productBox.delete(
      "reviews_$productId",
    );
  }

  // ================= CART =================

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

  // ================= USER =================

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

  // ================= ORDERS =================

  Future<void> saveOrders(
    String userId,
    List<Map<String, dynamic>> orders,
  ) async {
    await orderBox.put(
      "orders_$userId",
      orders,
    );
  }

  List getOrders(String userId) {
    return orderBox.get(
      "orders_$userId",
      defaultValue: [],
    );
  }

  Future<void> clearOrders(String userId) async {
    await orderBox.delete(
      "orders_$userId",
    );
  }

  // ================= CLEAR ALL =================

  Future<void> clearAll() async {
    await productBox.clear();
    await cartBox.clear();
    await userBox.clear();
    await orderBox.clear();
  }
  
}