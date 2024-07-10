import 'dart:convert';
import 'dart:typed_data';
import 'package:debenih_release/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';

class ApiService {
  static const String baseUrl = 'https://apidbenih.pythonanywhere.com/';
  final storage = const FlutterSecureStorage();

  final StreamController<Map<String, dynamic>> _detectionController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get detectionStream =>
      _detectionController.stream;

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

  Future<void> detectImage(Uint8List imageBytes) async {
    final token = await storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      _detectionController.add({'status': 'Token tidak ditemukan'});
      return;
    }

    _detectionController.add({'status': 'Mengunggah gambar...'});

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}detect'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final mimeType = lookupMimeType('', headerBytes: imageBytes);
      if (mimeType != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType.parse(mimeType),
        ));
      } else {
        _detectionController.add({'status': 'Gagal mendeteksi MIME type'});
        return;
      }

      final response = await request.send().timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);
        _detectionController.add({'status': 'Deteksi selesai', 'result': data});
      } else {
        _detectionController.add(
            {'status': 'Gagal mendeteksi gambar: ${response.statusCode}'});
      }
    } catch (e) {
      _detectionController.add({'status': 'Error saat mendeteksi gambar: $e'});
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
      throw Exception('Gagal menyimpan hasil deteksi');
    }
  }

  Future<Map<String, dynamic>?> detectFrame(Uint8List frameBytes) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print("No access token found");
      return null;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}detect_frame'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final mimeType = lookupMimeType('', headerBytes: frameBytes);
      if (mimeType == null) {
        print("Error: Could not determine MIME type for frameBytes");
        return null;
      }
      request.files.add(http.MultipartFile.fromBytes(
        'frame',
        frameBytes,
        filename: 'frame.jpg',
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);
        return data;
      } else {
        print("Gagal mendeteksi frame: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during detect frame request: $e");
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
    final token = await storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user_reports?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }
}