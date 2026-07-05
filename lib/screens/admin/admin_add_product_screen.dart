import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/product_color_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdminAddProductScreen
    extends StatefulWidget {
  const AdminAddProductScreen({
    super.key,
  });

  @override
  State<AdminAddProductScreen>
      createState() =>
          _AdminAddProductScreenState();
}

class _AdminAddProductScreenState
    extends State<AdminAddProductScreen> {
  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final stockController =
      TextEditingController();

  final List<XFile> images = [];
final List<ProductColorInput> colors = [];
  final List<String> selectedSizes =
      [];

  String selectedGender = "men";
  String selectedCategory =
      "tshirt";

  final ImagePicker picker =
      ImagePicker();

  Future<void> pickImages() async {
    final picked =
        await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      images.clear();
      images.addAll(picked);
      setState(() {});
    }
  }

  Future<void> saveProduct() async {
    final admin =
        context.read<AdminController>();

    if (nameController.text.isEmpty ||
        descriptionController
            .text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        images.isEmpty ||
        selectedSizes.isEmpty) {
      return;
    }

    final success =
    await admin.addProduct(
  name: nameController.text.trim(),
  description:
      descriptionController.text.trim(),
  price: double.parse(
    priceController.text,
  ),
  colorImages: colors,
  sizes: selectedSizes,
  stock: int.parse(
    stockController.text,
  ),
  gender: selectedGender,
  category: selectedCategory,
);
  }

  @override
  Widget build(BuildContext context) {
    final admin =
        context.watch<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Add Product"),
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
                selectedGender = value!;
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
                selectedCategory = value!;
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
                    if (val) {
                      selectedSizes.add(
                        size,
                      );
                    } else {
                      selectedSizes.remove(
                        size,
                      );
                    }

                    setState(() {});
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImages,
              child: const Text(
                "Pick Images",
              ),
            ),

            const SizedBox(height: 20),

            if (images.isNotEmpty)
              Wrap(
                spacing: 8,
                children:
                    images.map((img) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      color:
                          Colors.grey[300],
                    ),
                    child: const Icon(
                      Icons.image,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    admin.isLoading
                        ? null
                        : saveProduct,
                child:
                    admin.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Save Product",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}