import 'model_service.dart';
import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _cameraService = CameraService._internal();

  factory CameraService() {
    return _cameraService;
  }

  CameraService._internal();

  final TensorflowService _tensorflowService = TensorflowService();

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  bool available = true;

  Future<void> startService(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _cameraController?.dispose();
  }

  Future<void> startStreaming() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((img) async {
      try {
        if (available) {
          available = false;
          await _tensorflowService.runModel(img);
          await Future.delayed(const Duration(seconds: 1));
          available = true;
        }
      } catch (e) {
        print('Error running model with current frame: $e');
      }
    });
  }

  Future<void> stopImageStream() async {
    if (_cameraController == null || !_cameraController!.value.isStreamingImages) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();
    } catch (e) {
      rethrow;
    }
  }
}
