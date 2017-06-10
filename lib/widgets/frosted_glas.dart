import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FrostedGlass extends StatelessWidget{

  final Widget child;
  final double sigma;
  final double opacity;

  FrostedGlass({this.child, this.sigma: 5.0, this.opacity: 0.5});

  @override
  Widget build(BuildContext context) {
    Widget w = new Container(
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: sigma  , sigmaY: sigma),
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white.withOpacity(opacity)
          ),
          child: new Center(
              child: child
          ),
        ),
      ),
    );

    return w;
  }
}