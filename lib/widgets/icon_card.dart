import 'package:flutter/material.dart';

class IconCard extends StatelessWidget {
  final String iconPath;

  const IconCard({
    Key? key,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF5B86E5).withOpacity(0.4), const Color(0xFF36D1DC).withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.asset(iconPath, width: 24, height: 24, color: Colors.white),
      ),
    );
  }
}
