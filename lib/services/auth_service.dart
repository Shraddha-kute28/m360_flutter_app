import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../core/token_storage.dart';

class AuthService {

  /// 🔐 LOGIN (NO TOKEN EVER)
  static Future<bool> login(String username, String password) async {
    try {
      final response = await ApiClient.postWithoutToken(
        ApiConstants.login,
        {
          'userName': username,
          'password': password,
        },
      );

      print('STATUS => ${response.statusCode}');
      print('BODY => ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final String token = data['token'];
        final String name = data['name'] ?? 'User';
        final String role = data['roleName'] ?? 'EMPLOYEE';

        await TokenStorage.saveToken(token);
        await TokenStorage.saveName(name);
        await TokenStorage.saveRole(role);

        return true;
      }

      return false;
    } catch (e) {
      print('LOGIN ERROR => $e');
      return false;
    }
  }

  /// 🚪 LOGOUT
  static Future<void> logout() async {
    // optional backend logout API
    await TokenStorage.clear();
  }
}
