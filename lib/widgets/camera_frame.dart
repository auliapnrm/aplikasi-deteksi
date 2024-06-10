import 'package:flutter/material.dart';

class CameraFrame extends StatelessWidget {
  const CameraFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _focusLineWidth = 2.0;
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: _focusLineWidth),
                    left: BorderSide(color: Colors.white, width: _focusLineWidth),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: _focusLineWidth),
                    right: BorderSide(color: Colors.white, width: _focusLineWidth),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: _focusLineWidth),
                    right: BorderSide(color: Colors.white, width: _focusLineWidth),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: _focusLineWidth),
                    left: BorderSide(color: Colors.white, width: _focusLineWidth),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
