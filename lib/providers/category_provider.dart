import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? selectedCategory;

  final categoryBox = Hive.box("categories");
  final pendingBox = Hive.box("pending_ops");

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  // Load from cache first, then try API
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    // ✅ Load from cache
    final cached = categoryBox.values.toList();
    if (cached.isNotEmpty) {
      _categories = cached.cast<Map<String, dynamic>>();
      notifyListeners();
    }

    try {
      final data = await CategoryService.getCategories();
      _categories = data;
      await categoryBox.clear();
      await categoryBox.addAll(data);
    } catch (e) {
      print("Error fetching categories (offline mode): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<void> addCategory(Map<String, dynamic> newCategory) async {
    _categories.add(newCategory);
    await categoryBox.add(newCategory);
    notifyListeners();

    try {
      final created = await CategoryService.createCategory(newCategory);
      // update cache with server response
      _categories[_categories.length - 1] = created;
      await categoryBox.putAt(categoryBox.length - 1, created);
    } catch (e) {
      // queue for sync later
      await pendingBox.add({"action": "create", "data": newCategory});
      print("Queued category for later sync: $newCategory");
    }
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((c) => c["id"] == id);
    await categoryBox.clear();
    await categoryBox.addAll(_categories);
    notifyListeners();

    try {
      await CategoryService.deleteCategory(id);
    } catch (e) {
      await pendingBox.add({"action": "delete", "id": id});
      print("Queued category delete for later sync: $id");
    }
  }

  // Sync pending when online
  Future<void> syncPending() async {
    for (var op in pendingBox.values) {
      try {
        if (op["action"] == "create") {
          await CategoryService.createCategory(op["data"]);
        } else if (op["action"] == "delete") {
          await CategoryService.deleteCategory(op["id"]);
        }
        // remove from pending if successful
        await op.delete();
      } catch (e) {
        print("Still pending: $op");
      }
    }
  }

  void setSelectedCategory(String? val) {
    selectedCategory = val;
    notifyListeners();
  }
}
