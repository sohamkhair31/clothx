import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../constants/app_secrets.dart';

class CloudinaryService {
  Future<String?> uploadImage({
    required File imageFile,
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

      // Upload preset
      request.fields["upload_preset"] = AppSecrets.uploadPreset;

      // Dynamic folder structure
      request.fields["folder"] = "products/$gender/$category";

      // Image file
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData =
            jsonDecode(await response.stream.bytesToString());

        return responseData["secure_url"];
      } else {
        print("Upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}