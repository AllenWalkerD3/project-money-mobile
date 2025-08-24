// services/account_service.dart
import 'api_service.dart';

class AccountService {
  static Future<List<dynamic>> getAccounts() async {
    return await ApiService.get("/accounts");
  }

  static Future<dynamic> createAccount(Map<String, dynamic> data) async {
    return await ApiService.post("/accounts", data);
  }

  static Future<dynamic> updateAccount(int id, Map<String, dynamic> data) async {
    return await ApiService.put("/accounts/$id", data);
  }

  static Future<void> deleteAccount(int id) async {
    return await ApiService.delete("/accounts/$id");
  }
}
