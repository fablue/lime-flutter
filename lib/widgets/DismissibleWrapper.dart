import 'package:flutter/widgets.dart';

/// This will automatically remove the dismissible
/// from the tree once it dismisses.
///
/// This is just a convenience wrapper around [Dismissible]
class DismissibleWrapper extends StatefulWidget {

  ///[Dismissible.key]
  final Key key;

  ///[Dismissible.child]
  final Widget child;

  ////[Dismissible.onDismissed]
  final DismissDirectionCallback onDismissed;

  ///[Dismissible.direction]
  final DismissDirection direction;

  DismissibleWrapper(
      {this.key, this.child, this.onDismissed, this.direction: DismissDirection
          .horizontal});

  @override
  State<StatefulWidget> createState() {
    return new _State();
  }
}

class _State extends State<DismissibleWrapper> {

  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
    Widget w;
    if (!dismissed) w = new Dismissible(key: widget.key, child: widget.child,
        direction: widget.direction,
        onDismissed: (x) {
          setState(() => dismissed = true);
          if (widget.onDismissed != null) widget.onDismissed(x);
        });

    w = new Container(child: w);
    return w;
  }
}