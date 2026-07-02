  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../controllers/review_controller.dart';
  import '../models/review_model.dart';
  import 'package:image_picker/image_picker.dart';
  import '../controllers/auth_controller.dart';
  import '../controllers/admin_controller.dart';
  import '../controllers/product_controller.dart';
  import '../controllers/cart_controller.dart';
  import '../controllers/order_controller.dart';
  import '../controllers/admin_order_controller.dart';

  import '../models/product_model.dart';
  import '../models/cart_model.dart';
  import '../models/order_model.dart';

  class TestScreen extends StatefulWidget {
    const TestScreen({super.key});

    @override
    State<TestScreen> createState() => _TestScreenState();
  }

  class _TestScreenState extends State<TestScreen> {
    ProductModel? selectedProduct;
    String selectedSize = "M";
    int quantity = 1;
    bool isLoading = false;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final reviewController = TextEditingController();

  double selectedRating = 5.0;

  List<XFile> selectedReviewImages = [];
  String selectedGender = "men";
  String selectedCategory = "hoodies";


  Future<void> showAddReviewDialog(
    BuildContext context,
    ProductModel product,
  ) async {
    final review = context.read<ReviewController>();
    final auth = context.read<AuthController>();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Review"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(
                        labelText: "Comment",
                      ),
                    ),

                    Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: selectedRating,
                      label: selectedRating.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRating = value;
                        });
                      },
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();

                        final files =
                            await picker.pickMultiImage();

                        if (files.isNotEmpty) {
                          selectedReviewImages = files;
                        }

                        setDialogState(() {});
                      },
                      child: const Text("Pick Review Images"),
                    ),

                    Text(
                      "Images: ${selectedReviewImages.length}",
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    await review.addReview(
                      productId: product.id,
                      userId: auth.currentUser!.uid,
                      userName: "Test User",
                      comment: reviewController.text.trim(),
                      rating: selectedRating,
                      imageFiles: selectedReviewImages,
                    );

                    await review.fetchReviews(product.id);

  if (mounted) {
    Navigator.pop(context);
  }

                    reviewController.clear();
                    selectedReviewImages.clear();
                    selectedRating = 5;
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> showAddProductDialog(
    BuildContext context,
  ) async {
    final admin = context.read<AdminController>();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Product"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Product Name",
                      ),
                    ),

                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),

                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Price",
                      ),
                    ),

                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Stock",
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: selectedGender,
                      items: const [
                        DropdownMenuItem(
                          value: "men",
                          child: Text("Men"),
                        ),
                        DropdownMenuItem(
                          value: "women",
                          child: Text("Women"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGender = value!;
                        });
                      },
                    ),

                    DropdownButton<String>(
                      value: selectedCategory,
                      items: const [
                        DropdownMenuItem(
                          value: "hoodies",
                          child: Text("Hoodies"),
                        ),
                        DropdownMenuItem(
                          value: "tshirts",
                          child: Text("T-Shirts"),
                        ),
                        DropdownMenuItem(
                          value: "shirts",
                          child: Text("Shirts"),
                        ),
                        DropdownMenuItem(
                          value: "pants",
                          child: Text("Pants"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),

                    Wrap(
                      spacing: 8,
                      children: ["S", "M", "L", "XL"].map((size) {
                        final selected =
                            selectedSizes.contains(size);

                        return FilterChip(
                          label: Text(size),
                          selected: selected,
                          onSelected: (_) {
                            setDialogState(() {
                              if (selected) {
                                selectedSizes.remove(size);
                              } else {
                                selectedSizes.add(size);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

  ElevatedButton(
    onPressed: () async {
      final ImagePicker picker = ImagePicker();

      final List<XFile> pickedFiles =
          await picker.pickMultiImage();

  if (pickedFiles.isNotEmpty) {
    selectedImages = pickedFiles;
  }

      setDialogState(() {});
    },
    child: const Text("Pick Images"),
  ),

            if (selectedImages.isNotEmpty)
    SizedBox(
      height: 120,
      width: double.maxFinite,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: selectedImages[index].readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 80,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),
                child: Image.memory(
                  snapshot.data!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    ),
                  ],
                ),
              ),

              actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Cancel"),
    ),

    Consumer<AdminController>(
      builder: (context, admin, _) {
        return ElevatedButton(
          onPressed: admin.isLoading
              ? null
              : () async {
                  final result = await admin.addProduct(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.parse(
                      priceController.text.trim(),
                    ),
                    imageFiles: selectedImages,
                    sizes: selectedSizes,
                    stock: int.parse(
                      stockController.text.trim(),
                    ),
                    gender: selectedGender,
                    category: selectedCategory,
                  );

                  if (!mounted) return;

                  if (result) {
                    nameController.clear();
                    descController.clear();
                    priceController.clear();
                    stockController.clear();

                    selectedSizes.clear();
                    selectedImages.clear();

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          admin.errorMessage ??
                              "Failed to add product",
                        ),
                      ),
                    );
                  }
                },
          child: admin.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text("Add Product"),
        );
      },
    ),
  ]
            )
            
            ;
          },
        );
      },
    );
  }
  List<String> selectedSizes = [];
  List<XFile> selectedImages = [];
    @override
    void initState() {
      super.initState();

      Future.microtask(() async {
        await context.read<ProductController>().fetchProducts();
        context.read<CartController>().loadCart();
      });
    }

    Widget sectionTitle(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final auth = context.watch<AuthController>();
      final admin = context.watch<AdminController>();
      final product = context.watch<ProductController>();
      final cart = context.watch<CartController>();
      final order = context.watch<OrderController>();
      final adminOrder = context.watch<AdminOrderController>();

      return Scaffold(
        appBar: AppBar(
          title: const Text("ClothX Backend Test"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Auth"),

              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await auth.signUp(
                        name: "Test User",
                        email: "test@gmail.com",
                        password: "123456",
                        phone: "9999999999",
                        address: "Pune",
                      );
                    },
                    child: const Text("Signup"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.login(
                        email: "test@gmail.com",
                        password: "123456",
                      );
                    },
                    child: const Text("Login"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),

              Text("Current User: ${auth.currentUser?.email ?? "None"}"),

              sectionTitle("Admin"),

              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await admin.fetchAdminProducts();
                    },
                    child: const Text("Fetch Admin Products"),
                  ),

                  ElevatedButton(
                    
    onPressed: () {
      showAddProductDialog(context);
    },
                  child: const Text("Add Product"),
                  ),
                ],
              ),

              sectionTitle("Products"),

              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await product.fetchProducts();
                    },
                    child: const Text("Refresh Products"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      product.loadFromCacheOnly();
                    },
                    child: const Text("Load Cache Only"),
                  ),
                ],
              ),

              ...product.products.map((p) {
                return Card(
                  child: ListTile(
                    leading: p.images.isNotEmpty
                        ? Image.network(
                            p.images.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image),

                    title: Text(p.name),

                    subtitle: Text(
                      """
  ₹${p.price}
  Stock: ${p.stock}
  Category: ${p.category}
  Gender: ${p.gender}
  Sizes: ${p.sizes.join(", ")}
  """,
                    ),

                    trailing: selectedProduct?.id == p.id
                        ? const Icon(Icons.check)
                        : null,

                    onTap: () async {
                      setState(() {
    selectedProduct = p;
    selectedSize = p.sizes.first;
    quantity = 1;
  });

  await context
      .read<ReviewController>()
      .fetchReviews(p.id);
                    },
                  ),
                );
              }),

              if (selectedProduct != null) ...[
                sectionTitle("Selected Product"),

                if (selectedProduct!.images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedProduct!.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(
                            selectedProduct!.images[index],
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                Text("Name: ${selectedProduct!.name}"),
                Text("Price: ₹${selectedProduct!.price}"),
                Text("Stock: ${selectedProduct!.stock}"),
                Text("Description: ${selectedProduct!.description}"),

                DropdownButton<String>(
                  value: selectedSize,
                  items: selectedProduct!.sizes.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedSize = value);
                  },
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      onPressed: () {
                        if (quantity < selectedProduct!.stock) {
                          setState(() => quantity++);
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () async {
                    await cart.addToCart(
                      CartModel(
                        productId: selectedProduct!.id,
                        name: selectedProduct!.name,
                        image: selectedProduct!.images.first,
                        price: selectedProduct!.price,
                        size: selectedSize,
                        quantity: quantity,
                      ),
                    );
                  },
                  child: const Text("Add To Cart"),
                ),

                ElevatedButton(
    onPressed: () {
      showAddReviewDialog(
        context,
        selectedProduct!,
      );
    },
    child: const Text("Add Review"),
  ),
  sectionTitle("Product Reviews"),

  ...context
      .watch<ReviewController>()
      .reviews
      .map((review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              review.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text("⭐ ${review.rating}"),

            Text(review.comment),

            if (review.images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(8),
                      child: Image.network(
                        review.images[index],
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }),
              ],

              sectionTitle("Cart"),

              ...cart.cartItems.map((item) {
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      "Size: ${item.size} | Qty: ${item.quantity}",
                    ),
                    trailing: Text(
                      "₹${item.price * item.quantity}",
                    ),
                  ),
                );
              }),

              Text("Cart Total: ₹${cart.totalPrice}"),

              ElevatedButton(
                onPressed: () async {
                  if (auth.currentUser == null) return;

                  await order.placeOrder(
                    userId: auth.currentUser!.uid,
                    items: cart.cartItems,
                    totalAmount: cart.totalPrice,
                    cartController: cart,
                  );
                },
                child: const Text("Place Order"),
              ),

              sectionTitle("My Orders"),

              ElevatedButton(
                onPressed: () async {
                  if (auth.currentUser == null) return;
                  await order.fetchOrders(auth.currentUser!.uid);
                },
                child: const Text("Fetch My Orders"),
              ),

              ...order.orders.map((o) {
                return Card(
                  child: ListTile(
                    title: Text(o.orderId),
                    subtitle: Text(
                      "${o.orderStatus} | ₹${o.totalAmount}",
                    ),
                  ),
                );
              }),

              sectionTitle("Admin Orders"),

              ElevatedButton(
                onPressed: () async {
                  await adminOrder.fetchOrders();
                },
                child: const Text("Fetch All Orders"),
              ),

              ...adminOrder.orders.map((o) {
                return Card(
                  child: ListTile(
                    title: Text(o.orderId),
                    subtitle: Text(
                      "${o.orderStatus} | ₹${o.totalAmount}",
                    ),
                  ),
                );
              }),

              sectionTitle("Cache Debug"),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text("Cache Used: ${product.loadedFromCache}"),
                      Text("Server Fetch: ${product.loadedFromServer}"),
                      Text("Last Cache Load: ${product.lastCacheLoad}"),
                      Text("Last Server Fetch: ${product.lastServerFetch}"),
                      const Divider(),
                      Text("Products: ${product.products.length}"),
                      Text("Cart: ${cart.cartItems.length}"),
                      Text("Orders: ${order.orders.length}"),
                      Text("Admin Orders: ${adminOrder.orders.length}"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }