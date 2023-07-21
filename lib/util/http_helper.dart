import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to make GET request: ${response.statusCode}');
    }
  }
}