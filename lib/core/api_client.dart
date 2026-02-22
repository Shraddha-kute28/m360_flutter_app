import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);

  /// 🌍 PUBLIC API (NO TOKEN)
  static Future<http.Response> postWithoutToken(
      String url,
      Map<String, dynamic> body,
      ) async {
    final client = http.Client();

    try {
      return await client.post(
        Uri.parse(url),
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } finally {
      client.close();
    }
  }

  /// 🔐 PROTECTED GET API (TOKEN ONLY IF EXISTS)
  static Future<http.Response> getWithToken(String url) async {
    final token = await TokenStorage.getToken();

//ppp
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
    print('AUTH HEADERS => $headers');
    return http
        .get(Uri.parse(url), headers: headers)
        .timeout(_timeout);
  }

  /// 🔐 PROTECTED POST API (TOKEN ONLY IF EXISTS)
  static Future<http.Response> postWithToken(
      String url,
      Map<String, dynamic> body,
      ) async {
    final token = await TokenStorage.getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    return http
        .post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    )
        .timeout(_timeout);
  }
}
