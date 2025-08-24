// transaction_service.dart
import 'api_service.dart';

class TransactionService {
  static Future<List<dynamic>> getTransactions() async {
    return await ApiService.get("/transactions/transactions/book/2"); // need to update this for release.
  }

  static Future<dynamic> createTransaction(Map<String, dynamic> data) async {
    return await ApiService.post("/transactions", data);
  }

  static Future<dynamic> updateTransaction(int id, Map<String, dynamic> data) async {
    return await ApiService.put("/transactions/$id", data);
  }

  static Future<void> deleteTransaction(int id) async {
    return await ApiService.delete("/transactions/$id");
  }
}
