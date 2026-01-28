import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Author: Nicos Kasenides
/// Provides functionality for inference using Roboflow's ASL model
/// Predictive analysis on image data
class InferenceService {

  static Future<Map<String, dynamic>> classifyFromCameraBytes(
      Uint8List imageBytes,
      ) async {
    final uri = Uri.parse(
      'https://serverless.roboflow.com/asl-american-sign-language/1?api_key=dk3pAbfe8gENG1bHC1oR',
    );

    final request = http.MultipartRequest('POST', uri)
      // ..headers['Authorization'] = 'Bearer YOUR_API_KEY'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'frame.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    return jsonDecode(body);
  }

}


