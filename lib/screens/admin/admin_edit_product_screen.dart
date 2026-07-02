import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminEditProductScreen
    extends StatefulWidget {
  final ProductModel product;

  const AdminEditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<AdminEditProductScreen>
      createState() =>
          _AdminEditProductScreenState();
}

class _AdminEditProductScreenState
    extends State<AdminEditProductScreen> {
  late TextEditingController
      nameController;

  late TextEditingController
      descriptionController;

  late TextEditingController
      priceController;

  late TextEditingController
      stockController;

  late String selectedGender;
  late String selectedCategory;

  late List<String> selectedSizes;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    nameController =
        TextEditingController(
      text: product.name,
    );

    descriptionController =
        TextEditingController(
      text: product.description,
    );

    priceController =
        TextEditingController(
      text: product.price.toString(),
    );

    stockController =
        TextEditingController(
      text: product.stock.toString(),
    );

    selectedGender =
        product.gender;

    selectedCategory =
        product.category;

    selectedSizes =
        List.from(product.sizes);
  }

  Future<void> updateProduct() async {
    final admin =
        context.read<AdminController>();

    final updatedProduct =
        widget.product.copyWith(
      name:
          nameController.text.trim(),
      description:
          descriptionController.text.trim(),
      price: double.parse(
        priceController.text,
      ),
      stock: int.parse(
        stockController.text,
      ),
      gender: selectedGender,
      category: selectedCategory,
      sizes: selectedSizes,
    );

    final success =
        await admin.updateProduct(
      updatedProduct,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin =
        context.watch<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Edit Product"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Product Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  descriptionController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    "Description",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Price",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  stockController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Stock",
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
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
                setState(() {
                  selectedGender =
                      value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedCategory,
              items: const [
                DropdownMenuItem(
                  value: "tshirt",
                  child: Text("T-Shirt"),
                ),
                DropdownMenuItem(
                  value: "hoodie",
                  child: Text("Hoodie"),
                ),
                DropdownMenuItem(
                  value: "shirt",
                  child: Text("Shirt"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory =
                      value!;
                });
              },
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              children: [
                "S",
                "M",
                "L",
                "XL"
              ].map((size) {
                return FilterChip(
                  label: Text(size),
                  selected:
                      selectedSizes.contains(
                    size,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedSizes.add(
                          size,
                        );
                      } else {
                        selectedSizes.remove(
                          size,
                        );
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    admin.isLoading
                        ? null
                        : updateProduct,
                child:
                    admin.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Update Product",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}