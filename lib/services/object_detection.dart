import 'dart:typed_data';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ObjectDetection {
  ObjectDetection() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/yolov9.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<List<dynamic>?> detectObjects(Uint8List imageBytes) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: "", // Tambahkan argumen path sebagai string kosong
      imageMean: 127.5, // Tambahkan imageMean
      imageStd: 127.5, // Tambahkan imageStd
      numResultsPerClass: 1,
      threshold: 0.4,
      asynch: true,
    );
    return recognitions;
  }

  Future<List<dynamic>?> detectObjectsOnFrame(CameraImage image) async {
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      threshold: 0.4,
    );
    return recognitions;
  }
}

class ObjectPainter extends CustomPainter {
  final List<dynamic> recognitions;
  final Uint8List imageBytes;
  final Size imageSize;

  ObjectPainter({
    required this.recognitions,
    required this.imageBytes,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var recognition in recognitions) {
      final rect = Rect.fromLTRB(
        recognition['rect']['x'] * imageSize.width,
        recognition['rect']['y'] * imageSize.height,
        recognition['rect']['w'] * imageSize.width,
        recognition['rect']['h'] * imageSize.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
