import 'dart:async';
import 'package:flutter/material.dart';

class Recognition extends StatefulWidget {
  const Recognition({Key? key, required this.ready}) : super(key: key);

  final bool ready;

  @override
  _RecognitionState createState() => _RecognitionState();
}

enum SubscriptionState { Active, Done }

class _RecognitionState extends State<Recognition> {
  final List<dynamic> _currentRecognition = [];

  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();

    _startRecognitionStreaming();
  }

  _startRecognitionStreaming() {
    _streamSubscription;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal:
                        BorderSide(color: Color(0xFFD8D8D8), width: 0.5),
                  ),
                  color: Color(0xFFFFFFFF),
                ),
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: widget.ready
                      ? <Widget>[
                          _titleWidget(),
                          _contentWidget(),
                        ]
                      : <Widget>[],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const <Widget>[
          Text(
            "Deteksi Realtime",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _contentWidget() {
    var _width = MediaQuery.of(context).size.width;
    var _padding = 20.0;
    var _labelWitdth = 150.0;
    var _labelConfidence = 30.0;
    var _barWitdth = _width - _labelWitdth - _labelConfidence - _padding * 2.0;

    if (_currentRecognition.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        height: 150,
        child: ListView.builder(
          itemCount: _currentRecognition.length,
          itemBuilder: (context, index) {
            if (_currentRecognition.length > index) {
              return SizedBox(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: _padding, right: _padding),
                      width: _labelWitdth,
                      child: Text(
                        _currentRecognition[index]['label'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: _barWitdth,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        value: _currentRecognition[index]['confidence'],
                      ),
                    ),
                    SizedBox(
                      width: _labelConfidence,
                      child: Text(
                        (_currentRecognition[index]['confidence'] * 100)
                                .toStringAsFixed(0) +
                            '%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      return const Text('');
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
