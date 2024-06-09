import 'dart:typed_data';
import 'package:flutter/material.dart';

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
        recognition['rect']['x'] * size.width,
        recognition['rect']['y'] * size.height,
        recognition['rect']['w'] * size.width,
        recognition['rect']['h'] * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
