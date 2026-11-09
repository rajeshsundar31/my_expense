import 'package:flutter/widgets.dart';
import 'package:my_expense/core/constant/secure_store.dart';
import 'package:my_expense/core/service/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  Future<bool> userLogin(String email, String password) async {
    try {
      final response = await _api.verifiyUser("/auth/verifiy", {
        'grant_type': 'password',
        'username': email,
        'password': password,
      }, isForm: true);
      final token = response['access_token'];

      await TokenStorage.saveToken(token.toString());
      debugPrint('Register response: $token');
      return true;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }
}
