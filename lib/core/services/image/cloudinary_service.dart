import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../constants/app_secrets.dart';

class CloudinaryService {
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String gender,
    required String category,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${AppSecrets.cloudName}/image/upload",
      );

      final request = http.MultipartRequest(
        "POST",
        url,
      );

      request.fields["upload_preset"] =
          AppSecrets.uploadPreset;

      request.fields["folder"] =
          "products/$gender/$category";

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(
          await response.stream.bytesToString(),
        );

        return responseData["secure_url"];
      }

      return null;
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
  Future<String?> uploadReviewImage({
  required Uint8List imageBytes,
  required String fileName,
  required String productId,
}) async {
  try {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/${AppSecrets.cloudName}/image/upload",
    );

    final request = http.MultipartRequest(
      "POST",
      url,
    );

    request.fields["upload_preset"] =
        AppSecrets.uploadPreset;

    request.fields["folder"] =
        "reviews/$productId";

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        imageBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final data = jsonDecode(
        await response.stream.bytesToString(),
      );

      return data["secure_url"];
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
}
}