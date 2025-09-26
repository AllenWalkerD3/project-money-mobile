import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  final txBox = Hive.box("transactions");   // cached transactions
  final pendingBox = Hive.box("pending_tx"); // pending sync actions

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;

  /// Fetch transactions for a book
  Future<void> fetchTransactions(int bookId, int? categoryId, DateTime? startDate, DateTime? endDate,) async {
    _isLoading = true;
    notifyListeners();

    // ✅ Load from cache first
    final cached = txBox.values.where((tx) => tx["book_id"] == bookId).toList();
    if (cached.isNotEmpty) {
      _transactions = cached.cast<Map<dynamic, dynamic>>();
      notifyListeners();
    }

    try {
      final data = await TransactionService.getTransactionsByBook(bookId, categoryId, startDate, endDate);
      _transactions = data;

      // clear old cache & replace with latest
      await txBox.clear();
      await txBox.addAll(data);
    } catch (e) {
      print("Offline mode, showing cached transactions");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new transaction
  Future<void> addTransaction(Map<String, dynamic> newTx) async {
    // optimistic update
    _transactions.add(newTx);
    await txBox.add(newTx);
    notifyListeners();

    try {
      final created = await TransactionService.createTransaction(newTx);

      // replace optimistic entry with server entry
      _transactions[_transactions.length - 1] = created;
      await txBox.putAt(txBox.length - 1, created);
    } catch (e) {
      await pendingBox.add({"action": "create", "data": newTx});
      print("Queued transaction for later sync: $newTx");
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(int id) async {
    _transactions.removeWhere((tx) => tx["id"] == id);
    await txBox.clear();
    await txBox.addAll(_transactions);
    notifyListeners();

    try {
      await TransactionService.deleteTransaction(id);
    } catch (e) {
      await pendingBox.add({"action": "delete", "id": id});
      print("Queued delete transaction $id for later sync");
    }
  }

  /// Sync pending offline operations
  Future<void> syncPending() async {
    for (var op in pendingBox.values.toList()) {
      try {
        if (op["action"] == "create") {
          await TransactionService.createTransaction(op["data"]);
        } else if (op["action"] == "delete") {
          await TransactionService.deleteTransaction(op["id"]);
        }
        await op.delete();
      } catch (e) {
        print("Still pending: $op");
      }
    }
  }
}
