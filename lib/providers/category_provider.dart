import 'package:flutter/material.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool _isLoading = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  // Fetch all categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await CategoryService.getCategories();
      _categories = data;
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<void> addCategory(Map<String, dynamic> newCategory) async {
    try {
      final category = await CategoryService.createCategory(newCategory);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      print("Error creating category: $e");
    }
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    try {
      await CategoryService.deleteCategory(id);
      _categories.removeWhere((c) => c["id"] == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}
