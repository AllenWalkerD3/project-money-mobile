// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1";

  static final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"), headers: headers);
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl$endpoint"), headers: headers, body: jsonEncode(data));
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl$endpoint"), headers: headers, body: jsonEncode(data));
    return _handleResponse(response);
  }

  static Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse("$baseUrl$endpoint"), headers: headers);
    _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception("API Error: ${response.statusCode} ${response.body}");
    }
  }
}
