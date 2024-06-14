import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:beras_app/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.64.183:5000/';
  final storage = const FlutterSecureStorage();

  Future<UserModel?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
      return UserModel.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> register(
      String username, String namaLengkap, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'nama_lengkap': namaLengkap,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> detectImage(Uint8List imageBytes) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print("No token found");
      return null;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}detect'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: 'image.jpg'));

      final response =
          await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data;
      } else {
        print("Failed to detect image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during detect image request: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
  }

  Future<void> saveDetectionResults(
      UserModel user, Map<String, int> detectionCounts) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('${baseUrl}save_detection_results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'detection_counts': detectionCounts,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save detection results');
    }
  }

  Future<Map<String, dynamic>?> detectFrame(Uint8List frameBytes) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print("No access token found");
      return null;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}detect_frame'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes('frame', frameBytes,
        filename: 'frame.jpg'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data;
    } else {
      print("Failed to detect frame: ${response.statusCode}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserStatistics(String userId) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('${baseUrl}user_statistics'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch user statistics');
    }
  }

  Future<List<Map<String, dynamic>>> getUserReports(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user_reports?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token_here',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }
}
