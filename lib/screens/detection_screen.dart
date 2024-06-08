import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:beras_app/services/object_detection.dart';
import 'package:beras_app/models/user_model.dart';

class DetectionScreen extends StatelessWidget {
  final List<dynamic> recognitions;
  final Uint8List imageBytes;
  final UserModel user;
  final Size imageSize;

  const DetectionScreen({
    Key? key,
    required this.recognitions,
    required this.imageBytes,
    required this.user,
    required this.imageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Results'),
      ),
      body: Center(
        child: Column(
          children: [
            if (imageBytes.isNotEmpty)
              SizedBox(
                width: imageSize.width,
                height: imageSize.height,
                child: CustomPaint(
                  painter: ObjectPainter(
                    recognitions: recognitions,
                    imageBytes: imageBytes,
                    imageSize: imageSize,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: recognitions.length,
                itemBuilder: (context, index) {
                  final recognition = recognitions[index];
                  return ListTile(
                    title: Text('Label: ${recognition['label']}'),
                    subtitle: Text('Confidence: ${(recognition['confidence'] * 100).toStringAsFixed(2)}%'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
