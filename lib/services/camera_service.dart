import 'package:camera/camera.dart';

class CameraService {
  CameraController? cameraController;

  Future<void> startService(CameraDescription cameraDescription) async {
    cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    await cameraController!.initialize();
  }

  Future<void> startStreaming() async {
    if (cameraController != null) {
      cameraController!.startImageStream((CameraImage image) {
      });
    }
  }

  Future<void> stopImageStream() async {
    if (cameraController != null) {
      await cameraController!.stopImageStream();
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}
