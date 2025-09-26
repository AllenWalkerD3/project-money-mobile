// services/report_service.dart
import 'api_service.dart';

class ReportService {
  // ✅ Fetch account types
  static Future<List<dynamic>> getAccountTypes() async {
    return await ApiService.get(
      "/bookings/account-type?skip=0&limit=100",
    );
  }

  // ✅ Spending by account type
  static Future<dynamic> getSpendingByAccountType({
    required int accountTypeId,
    required String startDate,
    required String endDate,
  }) async {
    return await ApiService.get(
      "/reports/reports/spending-by-account-type?account_type_id=$accountTypeId&start_date=$startDate&end_date=$endDate",
    );
  }

  // ✅ Spending by category
  static Future<List<dynamic>> getSpendingByCategory({
    required int userId,
    required int bookId,
    required String transactionType, // e.g. "expense"
    required int accountTypeId,
    required String startDate,
    required String endDate,
  }) async {
    return await ApiService.get(
      "/reports/reports/get-spending-by-category?user_id=$userId&book_id=$bookId&transaction_type=$transactionType&account_type_id=$accountTypeId&start_date=$startDate&end_date=$endDate",
    );
  }
}
