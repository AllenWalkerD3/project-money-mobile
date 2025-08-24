import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Fetch all transactions
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await TransactionService.getTransactions();
      _transactions = data;
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a transaction
  Future<void> addTransaction(Map<String, dynamic> newTx) async {
    try {
      final tx = await TransactionService.createTransaction(newTx);
      _transactions.add(tx);
      notifyListeners();
    } catch (e) {
      print("Error creating transaction: $e");
    }
  }
}
