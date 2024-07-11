import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../widgets/camera_preview.dart';

class RealTimeClassificationPage extends StatefulWidget {
  const RealTimeClassificationPage({super.key});

  @override
  RealTimeClassificationPageState createState() =>
      RealTimeClassificationPageState();
}

class RealTimeClassificationPageState
    extends State<RealTimeClassificationPage> {
  late CameraController _controller;
  late ImageLabeler _imageLabeler;
  bool _isDetecting = false;
  List<ImageLabel> _labels = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeImageLabeler();
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageLabeler.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller.initialize();
    _controller.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _processCameraImage(image);
      }
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _initializeImageLabeler() async {
    final modelPath = await getModelPath('assets/model_quantized.tflite');
    final options = LocalLabelerOptions(
      modelPath: modelPath,
      confidenceThreshold: 0.5,
    );
    _imageLabeler = ImageLabeler(options: options);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _processCameraImageToInputImage(image);
    try {
      final labels = await _imageLabeler.processImage(inputImage);
      setState(() {
        _labels = labels;
        _isDetecting = false;
      });
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      print('Error processing image: $e');
    }
  }

  InputImage _processCameraImageToInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    const InputImageRotation imageRotation = InputImageRotation.rotation0deg;
    const InputImageFormat inputImageFormat = InputImageFormat.yuv420;
    final planeData = image.planes.map((Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    }).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.previewSize!.height,
                height: _controller.value.previewSize!.width,
                child: CameraPreview(_controller),
              ),
            ),
          ),
          if (_labels.isNotEmpty)
            Positioned(
              bottom: 100, // Mengubah posisi card lebih ke atas
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _labels.map((label) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "${label.label}: ${(label.confidence * 100).toStringAsFixed(2)}%",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: Image.asset(
              'assets/camera_launcher.png',
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
