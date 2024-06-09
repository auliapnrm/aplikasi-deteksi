import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:beras_app/models/user_model.dart';
import 'package:beras_app/services/api_service.dart';

import 'customcircular.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {Key? key,
      required this.controller,
      required this.user,
      required this.apiService})
      : super(key: key);
  final CameraController controller;
  final UserModel user;
  final ApiService apiService;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late Future<void> _initializeControllerFuture;
  List<dynamic>? _recognitions;
  final Map<String, int> _detectionCounts = {
    'Bagus': 0,
    'Tidak Bagus': 0,
    'Kurang Bagus': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = widget.controller.initialize();
    widget.controller.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final bytes = _convertYUV420ToImage(image);
    final recognitions = await widget.apiService.detectFrame(bytes);
    if (recognitions != null && recognitions.isNotEmpty) {
      setState(() {
        _recognitions = recognitions;
        for (var recognition in recognitions) {
          final label = recognition['label'];
          if (_detectionCounts.containsKey(label)) {
            _detectionCounts[label] = _detectionCounts[label]! + 1;
          } else {
            _detectionCounts[label] = 1;
          }
        }
      });
    }
  }

  Uint8List _convertYUV420ToImage(CameraImage image) {
    // Your implementation here
    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                CameraPreview(widget.controller),
                if (_recognitions != null)
                  CustomPaint(
                    painter: ObjectPainter(
                      recognitions: _recognitions!,
                      imageSize: Size(
                        widget.controller.value.previewSize!.height,
                        widget.controller.value.previewSize!.width,
                      ),
                      imageBytes: Uint8List(0),
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
                child: CustomCircularProgressIndicator(
                    imagePath: 'assets/logo/circularcustom.png', size: 25));
          }
        },
      ),
    );
  }

  @override
  void dispose() async {
    await widget.apiService.saveDetectionResults(widget.user, _detectionCounts);
    widget.controller.stopImageStream();
    widget.controller.dispose();
    super.dispose();
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
