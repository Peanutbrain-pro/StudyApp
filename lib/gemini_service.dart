import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class GeminiService {
  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String uploadBaseUrl =
      "https://generativelanguage.googleapis.com/upload/v1beta/files";

  String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent";

  Future<String?> uploadFile(String filePath, String mimeType) async {
    final url = Uri.parse('$uploadBaseUrl?uploadType=media&key=$_apiKey');
    final file = File(filePath);

    try {
      final bytes = await file.readAsBytes();
      print("Uploading $filePath");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': mimeType,
          'Content-Length': bytes.length.toString(),
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileUri = data['file']['uri'];
        print("Upload successful! URI: $fileUri");

        return fileUri;
      } else {
        print("Upload Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getResponse(String prompt, {List<String>? fileUris}) async {
    final url = Uri.parse(baseUrl);

    List<Map<String, dynamic>> parts = [];

    if (fileUris != null && fileUris.isNotEmpty) {
      for (String fileUri in fileUris) {
        parts.add({
          "file_data": {
            "mime_type": lookupMimeType(fileUri),
            "file_uri": fileUri
          }
        });
      }
    }

    parts.add({"text": prompt});

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey!,
          },
          body: jsonEncode({
            "contents": [
              {"parts": parts}
            ],
            "generationConfig": {
              "thinkingConfig": {"thinkingBudget": "200"}
            }
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
