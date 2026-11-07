import 'package:flutter/material.dart';
import 'package:my_expense/core/service/api_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  Future<bool> addExpenseDetail(
    int amount,
    String category,
    String note,
    String date,
  ) async {
    try {
      final response = await _api.addDetails("/addexpense", {
        'amount': amount,
        'category': category,
        'note': note,
        'date': date,
      });
      debugPrint("resp ${response}");
      return true;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }
}
