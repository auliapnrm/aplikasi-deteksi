import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'camera_preview.dart';
import 'package:debenih_release/services/api_service.dart';
import 'package:debenih_release/models/user_model.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final UserModel user;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.user,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isDetecting = false;
  List<dynamic> _detections = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      _controller.startImageStream(_processCameraImage);
    });
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;

    _isDetecting = true;

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/frame.jpg';

      final bytes = _concatenatePlanes(image.planes);
      print('Image bytes length: ${bytes.length}');
      if (bytes.isNotEmpty) {
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        print('Image saved to: $filePath');
        await _sendImageToServer(filePath);
      } else {
        print('Error: No bytes to process');
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _sendImageToServer(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      print('Sending bytes to server, length: ${bytes.length}');
      if (bytes.isNotEmpty) {
        final result = await _apiService.detectFrame(bytes);

        if (result != null && result['detection_result'] != null) {
          setState(() {
            _detections = result['detection_result']['predictions'];
          });
        } else {
          print("Failed to detect frame or detection result is null");
        }
      } else {
        print('Error: No bytes to send to server');
      }
    } catch (e) {
      print("Error during send image to server: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
          ..._detections.map((detection) {
            final x = detection['x'];
            final y = detection['y'];
            final width = detection['width'];
            final height = detection['height'];
            final label = detection['class'];
            final confidence = detection['confidence'];

            return Positioned(
              left: x - width / 2,
              top: y - height / 2,
              width: width,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '$label ${(confidence * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      backgroundColor: Colors.red,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
