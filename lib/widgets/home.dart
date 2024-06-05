import 'package:beras_app/services/camera_service.dart';
import 'package:beras_app/services/model_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_header.dart';
import 'camera_screen.dart';
import 'detection.dart';

class Home extends StatefulWidget {
  final CameraDescription camera;

  const Home({
    required Key key,
    required this.camera,
  }) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TensorflowService _tensorflowService = TensorflowService();
  final CameraService _cameraService = CameraService();

  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    startUp();
  }

  Future<void> startUp() async {
    if (!mounted) {
      return;
    }
    if (_initializeControllerFuture == null) {
      _initializeControllerFuture = _cameraService.startService(widget.camera).then((value) async {
        await _tensorflowService.loadModel();
        startRecognitions();
      });
    } else {
      await _tensorflowService.loadModel();
      startRecognitions();
    }
  }

  Future<void> startRecognitions() async {
    try {
      await _cameraService.startStreaming();
    } catch (e) {
      print('Error streaming camera image: $e');
    }
  }

  Future<void> stopRecognitions() async {
    await _cameraService.stopImageStream();
    await _tensorflowService.stopRecognitions();
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
                CameraScreen(
                  controller: _cameraService.cameraController!,
                ),
                const CameraHeader(),
                const Recognition(
                  ready: true,
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Starts camera and then loads the tensorflow model
      startUp();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _cameraService.dispose();
    _tensorflowService.dispose();
    super.dispose();
  }
}
