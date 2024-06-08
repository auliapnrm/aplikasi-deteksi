import 'dart:typed_data';

import 'package:beras_app/models/user_model.dart';
import 'package:beras_app/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/object_detection.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.controller, required this.user}) : super(key: key);
  final CameraController controller;
  final UserModel user;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late ObjectDetection _objectDetection;
  List<dynamic>? _recognitions;
  final Map<String, int> _detectionCounts = {
    'Bagus': 0,
    'Tidak Bagus': 0,
    'Kurang Bagus': 0,
  };
  final ApiService _apiService = ApiService();
  Uint8List? _latestImageBytes;

  @override
  void initState() {
    super.initState();
    _objectDetection = ObjectDetection();
    widget.controller.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final recognitions = await _objectDetection.detectObjectsOnFrame(image);
    if (recognitions != null && recognitions.isNotEmpty) {
      setState(() {
        _recognitions = recognitions;
        for (var recognition in recognitions) {
          final label = recognition['detectedClass'];
          if (_detectionCounts.containsKey(label)) {
            _detectionCounts[label] = _detectionCounts[label]! + 1;
          } else {
            _detectionCounts[label] = 1;
          }
        }
        // Simpan frame terakhir sebagai Uint8List
        _latestImageBytes = _convertCameraImageToBytes(image);
      });
    }
  }

  Uint8List _convertCameraImageToBytes(CameraImage image) {
    return Uint8List.fromList(image.planes[0].bytes);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Object Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(widget.controller),
          if (_recognitions != null)
            CustomPaint(
              painter: ObjectPainter(
                recognitions: _recognitions!,
                imageBytes: _latestImageBytes ?? Uint8List(0),
                imageSize: Size(
                  widget.controller.value.previewSize!.height,
                  widget.controller.value.previewSize!.width,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _detectionCounts.entries.map((entry) {
                  return Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() async {
    await _apiService.saveDetectionResults(widget.user, _detectionCounts);
    widget.controller.stopImageStream();
    widget.controller.dispose();
    super.dispose();
  }
}
