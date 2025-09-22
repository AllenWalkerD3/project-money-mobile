import 'api_service.dart';

class BookService {
  static Future<List<dynamic>> getBooks() async {
    return await ApiService.get("/bookings/account-books");
  }

  static Future<dynamic> getBook(int bookId) async {
    return await ApiService.get("/bookings/account-books/$bookId");
  }

  static Future<dynamic> createBook(Map<String, dynamic> data) async {
    return await ApiService.post("/bookings/account-books", data);
  }

  static Future<dynamic> updateBook(int id, Map<String, dynamic> data) async {
    return await ApiService.put("/bookings/account-books/$id", data);
  }

  static Future<void> deleteBook(int id) async {
    return await ApiService.delete("/bookings/account-books/$id");
  }
}
