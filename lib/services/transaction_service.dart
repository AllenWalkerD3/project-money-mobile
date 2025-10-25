// transaction_service.dart
import 'api_service.dart';
import 'package:intl/intl.dart';

class TransactionService {
  static Future<List<dynamic>> getTransactions(int bookId) async {
    return await ApiService.get("/transactions/transactions/book/$bookId"); // need to update this for release.
  }
  static Future<List<dynamic>> getTransactionsByBook(int bookId, int? categoryId, DateTime? startDate, DateTime? endDate) async {
    final queryParams = {
      if (categoryId != null) "category_id": categoryId.toString(),
      if (startDate != null) "start_date": DateFormat('yyyy-MM-dd').format(startDate),
      if (endDate != null) "end_date": DateFormat('yyyy-MM-dd').format(endDate),
    };

    final uri = Uri.parse("/transactions/transactions/book/$bookId").replace(queryParameters: queryParams);
    try{
      final response = await ApiService.get(uri.toString());
      return response;
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> createTransaction(Map<String, dynamic> data) async {
    return await ApiService.post("/transactions/transactions", data);
  }

  static Future<dynamic> updateTransaction(int id, Map<String, dynamic> data) async {
    return await ApiService.put("/transactions/transactions/$id", data);
  }

  static Future<void> deleteTransaction(int id) async {
    return await ApiService.delete("/transactions/transactions/$id");
  }
}
