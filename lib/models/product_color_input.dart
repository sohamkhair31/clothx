import 'package:image_picker/image_picker.dart';

class ProductColorInput {
  String color;
  XFile? image;

  ProductColorInput({
    this.color = "",
    this.image,
  });
}