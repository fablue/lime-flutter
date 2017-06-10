import 'dart:math';
import 'package:flutter/widgets.dart';

class CircularClip extends StatelessWidget{

  final Widget child;
  final double clip;

  CircularClip({this.child, this.clip});

  @override
  Widget build(BuildContext context) {
    Widget w = new ClipOval(clipper: new _CustomClipper()..status =clip,child: child,);
    return w;
  }
}
class _CustomClipper extends CustomClipper<Rect> {

  double status = 1.0;

  @override
  Rect getClip(Size size) {
    Rect rect = new Rect.fromCircle(
        center: new Offset(size.width, size.height),
        radius: status * (sqrt(pow(size.width, 2) + pow(size.height, 2)))
    );

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}