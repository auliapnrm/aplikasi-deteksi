import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({super.key, required this.onToggle, required this.ripplesAnimationController});
  final Function onToggle;
  final AnimationController ripplesAnimationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none, alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            height: 200,
            child: _buildRipples(),
          ),
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.white),
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
          ),
          InkWell(
            onTap: () => onToggle(),
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFe91e63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: ripplesAnimationController, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(150 * ripplesAnimationController.value),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF00FF).withOpacity(1 - ripplesAnimationController.value),
      ),
    );
  }
}
