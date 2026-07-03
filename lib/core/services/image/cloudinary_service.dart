import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../constants/app_secrets.dart';

class CloudinaryService {
  // ================= GENERIC UPLOAD =================
  Future<String?> _upload({
    required Uint8List imageBytes,
    required String fileName,
    required String folder,
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

      request.fields["folder"] = folder;

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: fileName,
        ),
      );

      final response =
          await request.send().timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final responseData = jsonDecode(
        await response.stream.bytesToString(),
      );

      final rawUrl =
          responseData["secure_url"];

      return _optimizedUrl(rawUrl);
    } catch (e) {
      print(
        "Cloudinary Upload Error: $e",
      );
      return null;
    }
  }

  // ================= PRODUCT IMAGE =================
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String gender,
    required String category,
  }) async {
    return await _upload(
      imageBytes: imageBytes,
      fileName: fileName,
      folder:
          "products/$gender/$category",
    );
  }

  // ================= REVIEW IMAGE =================
  Future<String?> uploadReviewImage({
    required Uint8List imageBytes,
    required String fileName,
    required String productId,
  }) async {
    return await _upload(
      imageBytes: imageBytes,
      fileName: fileName,
      folder: "reviews/$productId",
    );
  }

  // ================= DELIVERY OPTIMIZATION =================
  String _optimizedUrl(
    String url,
  ) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_auto,dpr_auto/",
    );
  }
}