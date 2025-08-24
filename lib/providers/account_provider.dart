import 'package:flutter/material.dart';
import '../services/account_service.dart';

class AccountProvider with ChangeNotifier {
  List<dynamic> _accounts = [];
  bool _isLoading = false;

  List<dynamic> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AccountService.getAccounts();
      _accounts = data;
    } catch (e) {
      print("Error fetching accounts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
