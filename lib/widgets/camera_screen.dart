import 'package:beras_app/screens/realtime_detection.dart';
import 'package:beras_app/widgets/customcircular.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:beras_app/services/api_service.dart';
import 'package:beras_app/screens/detection_screen.dart';
import 'package:beras_app/models/user_model.dart';

import 'camera_header.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final UserModel user;
  final ApiService apiService;

  const CameraScreen({
    Key? key,
    required this.camera,
    required this.user,
    required this.apiService,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isDetecting = false;

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
      final bytes = _concatenatePlanes(image.planes);
      final result = await widget.apiService.detectFrame(bytes);

      if (result != null && result['result_image_path'] != null) {
        final imagePath = result['result_image_path'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      print('Failed to detect frame: $e');
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CustomCircularProgressIndicator(
            imagePath: 'assets/logo/circularcustom.png'),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
          const CameraHeader(),
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RealTimeDetectionPage()),
                    );
                  },
                  child: const Text('Real-time Detection'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
