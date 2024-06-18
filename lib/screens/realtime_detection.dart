import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RealTimeDetectionPage extends StatefulWidget {
  const RealTimeDetectionPage({Key? key}) : super(key: key);

  @override
  _RealTimeDetectionPageState createState() => _RealTimeDetectionPageState();
}

class _RealTimeDetectionPageState extends State<RealTimeDetectionPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeBenih Realtime Detection', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
       body: InAppWebView(
        initialFile: 'assets/roboflow.html',
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          controller.addJavaScriptHandler(
            handlerName: 'detect',
            callback: (args) {
              final predictions = args[0];
              print(predictions);
            },
          );
        },
        onLoadStop: (controller, url) {
          print("Page loaded: $url");
        },
        onLoadError: (controller, url, code, message) {
          print("Failed to load page: $url, Error: $code, Message: $message");
        },
      ),
    );
  }
}