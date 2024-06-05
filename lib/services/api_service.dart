import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.20.136:5000/';
  final storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> register(String username, String namaLengkap, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'nama_lengkap': namaLengkap,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  Future<String?> detectImage(File image) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      return null;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/detect'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['detection_result'];
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
  }
}
