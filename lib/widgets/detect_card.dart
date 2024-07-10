import 'package:flutter/material.dart';

class DetectCard extends StatelessWidget {
  final String iconPath;
  final Gradient gradient;
  final VoidCallback onTap;

  const DetectCard({
    Key? key,
    required this.iconPath,
    required this.gradient,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(iconPath, width: 24, height: 24, color: Colors.white),
        ),
      ),
    );
  }
}
