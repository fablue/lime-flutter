import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/widgets/loading_list_view.dart';
import 'package:lime/widgets/post.dart';
import 'package:lime/widgets/post_create.dart';

class Feed extends StatefulWidget {

  final int pageSize;
  final int pageThreshold;

  Feed({
    Key key,
    this.pageSize: 50,
    this.pageThreshold: 10
  }) :super(key: key);


  @override
  State<StatefulWidget> createState() {
    return new _FeedState();
  }


}

class _FeedState extends State<Feed> {

  var _buildContext;
  var _showModal = false;

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    List<Widget> stacked = [];



    Widget scaffold = new Scaffold(
        body: new LoadingListView<Map>(
            request, widgetAdapter: adapt, pageSize: widget.pageSize,
            pageThreshold: widget.pageThreshold),
        floatingActionButton: !_showModal? new FeedActionButton() :null
    );

    stacked.add(scaffold);
    _showModal? stacked.add(new FeedModal()) : null;
    return new Stack(
        children: stacked
    );
     }

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map>> request(int page, int pageSize) async {
    return lime.api.getFeed(paginationIndex: page, paginationSize: pageSize);
  }

  Widget adapt(Map map) {
    return new Post(map);
  }

  get showModal {
    return _showModal;
  }

  set showModal(bool showModal) {
    setState(() {
      this._showModal = showModal;
    });


  }


}


class FeedActionButton extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _FeedActionButtonState();
  }
}

class _FeedActionButtonState extends State<FeedActionButton> {

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new FloatingActionButton(
        child: new Icon(
            Icons.add,
            color: Theme
                .of(context)
                .iconTheme
                .color
        ),
        onPressed: onPressed,
        backgroundColor: Colors.white
    );
  }

  onPressed() {
    _FeedState feedState = _context.ancestorStateOfType(
        new TypeMatcher<_FeedState>());
    feedState.showModal = true;
  }
}


class FeedModal extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _FeedModalState();
  }
}


class _FeedModalState extends State<FeedModal> with TickerProviderStateMixin {
  AnimationController _clipController;
  AnimationController _blurController;
  double _fraction = 0.0;
  double _blur = 0.0;
  BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    Container container = new Container(
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 3.0 * _blur, sigmaY: 3.0 * _blur),
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white.withOpacity(0.90)
          ),
          child: new Center(
            child: new PostCreate()
          ),
        ),
      ),
    );

    Widget content = container;
    if(_fraction < 1) {
      content = new ClipOval(
          child: container,
          clipper: new _CustomClipper()
            ..status = _fraction
      );
    }

    Widget dismissible = new Dismissible(
      key: new ObjectKey(this),
      child: content,
      direction: DismissDirection.down,
      onDismissed: (x) {
        _FeedState feedState = _context.ancestorStateOfType(new TypeMatcher<_FeedState>());
        feedState?.showModal = false;
      }
      );

    return dismissible;
  }

  @override
  void initState() {
    super.initState();
    _clipController = new AnimationController(vsync: this
        , duration: const Duration(milliseconds: 200))
      ..addListener(() =>
          setState(() {
            this._fraction = _clipController.value;
          }
          ));
    _blurController = new AnimationController(vsync: this,
    duration: const Duration(milliseconds: 150))
    ..addListener(() => this.setState((){
      this._blur = _blurController.value;
    }));
    _clipController.forward().then((x) => _blurController.forward());
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