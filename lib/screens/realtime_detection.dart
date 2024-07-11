import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../widgets/camera_preview.dart';

class RealTimeDetectionPage extends StatefulWidget {
  const RealTimeDetectionPage({super.key});

  @override
  RealTimeDetectionPageState createState() => RealTimeDetectionPageState();
}

class RealTimeDetectionPageState extends State<RealTimeDetectionPage> {
  late CameraController _controller;
  late ObjectDetector _objectDetector;
  bool _isDetecting = false;
  List<DetectedObject> _detectedObjects = [];
  bool _isCameraInitialized = false;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeObjectDetector();
    _loadLabels();
  }

  @override
  void dispose() {
    _controller.dispose();
    _objectDetector.close();
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

  Future<void> _initializeObjectDetector() async {
    final modelPath = await getModelPath('assets/model.tflite');
    final options = LocalObjectDetectorOptions(
      modelPath: modelPath,
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.5,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _processCameraImageToInputImage(image);
    try {
      final objects = await _objectDetector.processImage(inputImage);
      setState(() {
        _detectedObjects = objects;
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

  Future<void> _loadLabels() async {
    final String labelsData = await rootBundle.loadString('assets/labels.txt');
    setState(() {
      _labels = labelsData.split('\n');
    });
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
          if (_detectedObjects.isNotEmpty)
            ..._detectedObjects.map((object) {
              return Positioned(
                left:
                    object.boundingBox.left * MediaQuery.of(context).size.width,
                top:
                    object.boundingBox.top * MediaQuery.of(context).size.height,
                width: object.boundingBox.width *
                    MediaQuery.of(context).size.width,
                height: object.boundingBox.height *
                    MediaQuery.of(context).size.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                  ),
                  child: Text(
                    "${_labels[object.labels.first.index]} ${(object.labels.first.confidence * 100).toStringAsFixed(2)}%",
                    style: const TextStyle(
                      backgroundColor: Colors.red,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
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
