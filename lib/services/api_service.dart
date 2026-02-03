import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/item_model.dart';
import 'dart:io' show Platform;

class ApiService {
  // Gunakan 10.0.2.2 untuk Android Emulator, atau IP Laptop (misal 192.168.1.5) untuk Device Asli
  // Gunakan localhost untuk iOS Simulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000";
    } else {
      return "http://localhost:3000";
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(
          response.body,
        ); // {success: true, id: ..., name: ...}
      }
      return {'success': false, 'message': 'Email atau password salah'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan backend jalan.',
      };
    }
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Items
  static Future<List<Item>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Item.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
    return [];
  }

  static Future<bool> createItem(Item item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteItem(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/items/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
