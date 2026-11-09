import 'package:flutter/material.dart';
import 'package:my_expense/core/service/api_service.dart';
import 'package:my_expense/page/expense/detail_expense.dart';

class DashboardViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // 1. State: the data and status the UI needs
  List<Expense> _expenseDataList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String username = '';

  // 2. Getters: the UI reads these (never the private fields)
  List<Expense> get expenseDataList => _expenseDataList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 3. Fetch method
  Future<void> fetchExpenseList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // tell the UI: show the loader

    try {
      final response = await _api.getDetails("/getdetails");

      // The API may return a list directly, or {"data": [...]}
      final List list = response is List
          ? response
          : (response is Map && response['data'] is List
                ? response['data']
                : []);

      // Convert each JSON item into an Expense object
      _expenseDataList = list
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _expenseDataList = [];
      _errorMessage = 'Unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners(); // tell the UI: data (or error) is ready
    }
  }

  void removeExpense(Expense expense) {
    _expenseDataList.removeWhere((e) => e.id == expense.id);
    notifyListeners();
  }

  Future<void> getUserName() async {
    try {
      final response = await _api.getDetails("/username");
      username = response['username'];
    } catch (e) {
      debugPrint(e as String?);
    }
    notifyListeners();
  }
}
