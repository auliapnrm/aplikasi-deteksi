import 'package:flutter/material.dart';

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
      final rect = Rect.fromLTWH(
        recognition['x'] * size.width / imageSize.width,
        recognition['y'] * size.height / imageSize.height,
        recognition['width'] * size.width / imageSize.width,
        recognition['height'] * size.height / imageSize.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
