import 'package:clothx/models/order_model.dart';
import 'package:hive/hive.dart';

class CacheService {
  static final CacheService _instance =
      CacheService._internal();

  factory CacheService() => _instance;

  CacheService._internal();
static const String addressBoxName =
    "addresses";
  static const String productBoxName =
      "products";
  static const String reviewBoxName =
      "reviews";
  static const String cartBoxName =
      "cart";
  static const String userBoxName =
      "user";
  static const String orderBoxName =
      "orders";
  static const String adminBoxName =
      "admin";
late Box addressBox;
  late Box productBox;
  late Box reviewBox;
  late Box cartBox;
  late Box userBox;
  late Box orderBox;
  late Box adminBox;

  Future<void> init() async {
    addressBox =
    await Hive.openBox(addressBoxName);
    productBox =
        await Hive.openBox(productBoxName);

    reviewBox =
        await Hive.openBox(reviewBoxName);

    cartBox =
        await Hive.openBox(cartBoxName);

    userBox =
        await Hive.openBox(userBoxName);

    orderBox =
        await Hive.openBox(orderBoxName);

    adminBox =
        await Hive.openBox(adminBoxName);
  }
  
  //================= ADDRESSES =================
  // ================= ADDRESSES =================

Future<void> saveAddresses(
  String userId,
  List<Map<String, dynamic>> addresses,
) async {
  await addressBox.put(
    "addresses_$userId",
    addresses,
  );
}

List getAddresses(String userId) {
  return addressBox.get(
    "addresses_$userId",
    defaultValue: [],
  );
}

Future<void> saveAddressesMeta(
  String userId,
  String meta,
) async {
  await addressBox.put(
    "addresses_meta_$userId",
    meta,
  );
}

String? getAddressesMeta(
  String userId,
) {
  return addressBox.get(
    "addresses_meta_$userId",
  );
}

Future<void> clearAddresses(
  String userId,
) async {
  await addressBox.delete(
    "addresses_$userId",
  );

  await addressBox.delete(
    "addresses_meta_$userId",
  );
}
  // ================= PRODUCTS =================
  Future<void> saveProducts(
    List<Map<String, dynamic>> products,
  ) async {
    await productBox.put(
      "product_list",
      products,
    );
  }

  List getProducts() {
    return productBox.get(
      "product_list",
      defaultValue: [],
    );
  }

  Future<void> clearProducts() async {
    await productBox.delete(
      "product_list",
    );
  }

  Future<void> saveLastMeta(
    String value,
  ) async {
    await productBox.put(
      "last_meta",
      value,
    );
  }

  String? getLastMeta() {
    return productBox.get("last_meta");
  }

  // ================= REVIEWS =================
  Future<void> saveReviews(
    String productId,
    List<Map<String, dynamic>> reviews,
  ) async {
    await reviewBox.put(
      "reviews_$productId",
      reviews,
    );
  }

  List getReviews(String productId) {
    return reviewBox.get(
      "reviews_$productId",
      defaultValue: [],
    );
  }

  Future<void> saveReviewMeta(
    String productId,
    String meta,
  ) async {
    await reviewBox.put(
      "review_meta_$productId",
      meta,
    );
  }

  String? getReviewMeta(
    String productId,
  ) {
    return reviewBox.get(
      "review_meta_$productId",
    );
  }

  Future<void> clearReviews(
    String productId,
  ) async {
    await reviewBox.delete(
      "reviews_$productId",
    );
  }

  // ================= CART =================
  Future<void> saveCart(
    List<Map<String, dynamic>> cartItems,
  ) async {
    await cartBox.put(
      "cart_items",
      cartItems,
    );
  }

  List getCart() {
    return cartBox.get(
      "cart_items",
      defaultValue: [],
    );
  }

  Future<void> clearCart() async {
    await cartBox.delete(
      "cart_items",
    );
  }

  // ================= USER =================
  Future<void> saveUser(
    Map<String, dynamic> userData,
  ) async {
    await userBox.put(
      "user_data",
      userData,
    );
  }

  Map<String, dynamic>? getUser() {
    final data =
        userBox.get("user_data");

    if (data == null) return null;

    return Map<String, dynamic>.from(data);
  }

  Future<void> clearUser() async {
    await userBox.delete(
      "user_data",
    );
  }

  // ================= ORDERS =================
// ================= ORDERS =================

Future<void> saveOrders(
  String userId,
  List<OrderModel> orders,
) async {
  await orderBox.put(
    "orders_$userId",
    orders
        .map((e) => e.toMap())
        .toList(),
  );
}

List<OrderModel> getOrders(
  String userId,
) {
  final data = orderBox.get(
    "orders_$userId",
    defaultValue: [],
  );

  return (data as List)
      .map<OrderModel>(
        (e) => OrderModel.fromMap(
          Map<String, dynamic>.from(e),
        ),
      )
      .toList();
}

Future<void> saveOrdersMeta(
  String userId,
  String meta,
) async {
  await orderBox.put(
    "orders_meta_$userId",
    meta,
  );
}

String? getOrdersMeta(
  String userId,
) {
  return orderBox.get(
    "orders_meta_$userId",
  );
}

Future<void> clearOrders(
  String userId,
) async {
  await orderBox.delete(
    "orders_$userId",
  );

  await orderBox.delete(
    "orders_meta_$userId",
  );
}
  // ================= ADMIN =================
  Future<void> saveAdminProducts(
    List<Map<String, dynamic>> products,
  ) async {
    await adminBox.put(
      "admin_products",
      products,
    );
  }

  List getAdminProducts() {
    return adminBox.get(
      "admin_products",
      defaultValue: [],
    );
  }

  Future<void> saveAdminMeta(
    String meta,
  ) async {
    await adminBox.put(
      "admin_meta",
      meta,
    );
  }

  String? getAdminMeta() {
    return adminBox.get(
      "admin_meta",
    );
  }

  // ================= CLEAR ALL =================
  Future<void> clearAll() async {
    await productBox.clear();
    await reviewBox.clear();
    await cartBox.clear();
    await userBox.clear();
    await orderBox.clear();
await adminBox.clear();
await addressBox.clear();
  }
}