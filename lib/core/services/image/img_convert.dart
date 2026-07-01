import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> convertToWebP(XFile file) async {
  final result =
      await FlutterImageCompress.compressAndGetFile(
    file.path,
    "${file.path}.webp",
    format: CompressFormat.webp,
    quality: 80,
  );

  return result;
}