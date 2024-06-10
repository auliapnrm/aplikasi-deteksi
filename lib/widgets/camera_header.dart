import 'package:flutter/material.dart';

class CameraHeader extends StatelessWidget {
  const CameraHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(
            image: AssetImage('assets/camera_launcher.png'),
            height: 40,
            width: 40,
          ),
        ],
      ),
    );
  }
}
