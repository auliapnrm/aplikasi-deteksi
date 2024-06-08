import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ObjectDetection {
  ObjectDetection();

  Future<List<dynamic>?> detectObjects(Uint8List imageBytes) async {
    // Menggunakan API Service untuk mendeteksi objek
  }

  Future<List<dynamic>?> detectObjectsOnFrame(Uint8List frameBytes) async {
    // Menggunakan API Service untuk mendeteksi objek pada frame
  }
}

class ObjectPainter extends CustomPainter {
  final List<dynamic> recognitions;
  final Size imageSize;

  ObjectPainter({
    required this.recognitions,
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
