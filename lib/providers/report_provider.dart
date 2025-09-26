// providers/report_provider.dart
import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  List<dynamic> _accountTypes = [];
  Map<int, double> _spendingByAccountType = {}; // {accountTypeId: totalSpent}
  List<dynamic> _spendingByCategory = [];

  List<dynamic> get accountTypes => _accountTypes;
  Map<int, double> get spendingByAccountType => _spendingByAccountType;
  List<dynamic> get spendingByCategory => _spendingByCategory;

  // ✅ Fetch account types
  Future<void> fetchAccountTypes() async {
    try {
      _accountTypes = await ReportService.getAccountTypes();
      notifyListeners();
    } catch (e) {
      print("Error fetching account types: $e");
    }
  }

  // ✅ Fetch spending by account type
  Future<void> fetchSpendingByAccountType({
    required int accountTypeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final result = await ReportService.getSpendingByAccountType(
        accountTypeId: accountTypeId,
        startDate: startDate,
        endDate: endDate,
      );

      // result = { "account_type_id": 2, "total_spent": 25052.1 }
      _spendingByAccountType[accountTypeId] = result["total_spent"] ?? 0.0;
      notifyListeners();
    } catch (e) {
      print("Error fetching spending by account type: $e");
    }
  }

  // ✅ Fetch spending by category
  Future<void> fetchSpendingByCategory({
    required int userId,
    required int bookId,
    required String transactionType,
    required int accountTypeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      _spendingByCategory = await ReportService.getSpendingByCategory(
        userId: userId,
        bookId: bookId,
        transactionType: transactionType,
        accountTypeId: accountTypeId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      print("Error fetching spending by category: $e");
    }
  }
}
