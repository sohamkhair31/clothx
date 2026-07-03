import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> convertToWebP(
  XFile file,
) async {
  final outputPath = file.path
      .replaceAll(
        RegExp(r'\.\w+$'),
        '.webp',
      );

  final result =
      await FlutterImageCompress.compressAndGetFile(
    file.path,
    outputPath,
    format: CompressFormat.webp,
    quality: 65,
    minWidth: 1200,
    minHeight: 1200,
  );

  if (result == null) {
    return null;
  }

  return XFile(result.path);
}