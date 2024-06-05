import 'dart:async';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TensorflowService {
  // Singleton boilerplate
  static final TensorflowService _tensorflowService = TensorflowService._internal();

  factory TensorflowService() {
    return _tensorflowService;
  }

  TensorflowService._internal();

  final StreamController<List<dynamic>> _recognitionController = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get recognitionStream => _recognitionController.stream;

  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
      _modelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> runModel(CameraImage img) async {
    if (_modelLoaded) {
      try {
        List<dynamic>? recognitions = await Tflite.runModelOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(), // required
          imageHeight: img.height,
          imageWidth: img.width,
          numResults: 3,
        );

        if (recognitions != null && recognitions.isNotEmpty) {
          print(recognitions[0].toString());
          if (!_recognitionController.isClosed) {
            _recognitionController.add(recognitions);
          }
        }
      } catch (e) {
        print('Error running model on frame: $e');
      }
    }
  }

  Future<void> stopRecognitions() async {
    if (!_recognitionController.isClosed) {
      _recognitionController.add([]);
      await _recognitionController.close();
    }
  }

  void dispose() {
    if (!_recognitionController.isClosed) {
      _recognitionController.close();
    }
  }
}
