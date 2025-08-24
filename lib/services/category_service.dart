// services/category_service.dart
import 'api_service.dart';

class CategoryService {
  static Future<List<dynamic>> getCategories() async {
    return await ApiService.get("/categories");
  }

  static Future<dynamic> createCategory(Map<String, dynamic> data) async {
    return await ApiService.post("/categories", data);
  }

  static Future<dynamic> updateCategory(int id, Map<String, dynamic> data) async {
    return await ApiService.put("/categories/$id", data);
  }

  static Future<void> deleteCategory(int id) async {
    return await ApiService.delete("/categories/$id");
  }
}
