import 'package:flutter/material.dart';
import 'package:my_expense/core/service/api_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns true if registration succeeded
  Future<bool> addRegisterUser(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.addUser('/auth/addUser', {
        'name': name,
        'email': email,
        'password': password,
      });

      debugPrint('Register response: $response');
      return true;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
