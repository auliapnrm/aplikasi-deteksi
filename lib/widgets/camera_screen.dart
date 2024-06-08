import 'package:beras_app/models/user_model.dart';
import 'package:beras_app/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_header.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.controller, required this.user, required this.apiService}) : super(key: key);
  final CameraController controller;
  final UserModel user;
  final ApiService apiService;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<dynamic>? _recognitions;
  final Map<String, int> _detectionCounts = {
    'Bagus': 0,
    'Tidak Bagus': 0,
    'Kurang Bagus': 0,
  };

  @override
  void initState() {
    super.initState();
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
    // Konversi image ke format yang dapat digunakan untuk pengiriman ke server
    // Implementasikan fungsi ini sesuai dengan format data yang diperlukan oleh server
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                CameraPreview(widget.controller),
                const CameraHeader(),
                if (_recognitions != null)
                  CustomPaint(
                    painter: ObjectPainter(
                      recognitions: _recognitions!,
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
            );
          } else {
            return const Center(child: CustomCircularProgressIndicator(
              imagePath: 'assets/logo/circularcustom.png', size: 15,
            ));
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
