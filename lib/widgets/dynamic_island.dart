import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DynamicIsland extends StatefulWidget {
  final String message;
  final bool isExpanded;
  final double height; // New height parameter

  const DynamicIsland(
      {super.key, required this.message, this.isExpanded = false, this.height = 30.0});

  @override
  DynamicIslandState createState() => DynamicIslandState();
}

class DynamicIslandState extends State<DynamicIsland>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation =
        Tween<double>(begin: 100.0, end: 250.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _heightAnimation =
        Tween<double>(begin: 50.0, end: widget.height).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(DynamicIsland oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      if (_controller.isCompleted || _controller.velocity > 0) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _widthAnimation.value,
              height: _heightAnimation.value,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: _controller.isDismissed
                    ? Lottie.asset(
                        'assets/animations/animation10.json',
                        width: 80,
                        height: 30,
                        fit: BoxFit.cover,
                      )
                    : Opacity(
                        opacity: _opacityAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.message,
                              style: const TextStyle(
                                  color: Colors.white, fontFamily: 'Poppins'),
                            ),
                            // Tambahkan informasi lain di sini
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}