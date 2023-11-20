import 'package:animator/animator.dart';
import 'package:flutter/material.dart';

///Animación de corazón al dar like
class HeartAnimationWidget extends StatefulWidget {
  bool visibility;
  HeartAnimationWidget({Key? key,required this.visibility}) : super(key: key);

  @override
  _HeartAnimationWidgetState createState() => _HeartAnimationWidgetState();
}


class _HeartAnimationWidgetState extends State<HeartAnimationWidget> {
  @override
  Widget build(BuildContext context) {
    return  Visibility(
        visible: widget.visibility,
        child: Animator(
          curve: Curves.elasticInOut,
          duration: const Duration(milliseconds: 500),
          tween: Tween<double?>(begin: 5.0, end: 25.0),
          repeats: 1,
          endAnimationListener: (p0) {
            debugPrint("${p0.controller.status}");
          },
          builder: (BuildContext context,
              AnimatorState animatorState,
              Widget? child) {
            return Icon(
              Icons.favorite,
              color: Colors.black.withRed(175),
              size: animatorState.value * 5,
            );
          },
        ));
  }
  }
