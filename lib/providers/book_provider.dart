import 'package:flutter/material.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  List<dynamic> _books = [];
  bool _isLoading = false;

  List<dynamic> get books => _books;
  bool get isLoading => _isLoading;

  // Fetch all books
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await BookService.getBooks();
      _books = data;
    } catch (e) {
      print("Error fetching books: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch one book by ID
  Future<Map<String, dynamic>?> fetchBookById(int bookId) async {
    try {
      final book = await BookService.getBook(bookId);
      return book;
    } catch (e) {
      print("Error fetching book: $e");
      return null;
    }
  }
}
