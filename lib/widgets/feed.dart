import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/widgets/DismissibleWrapper.dart';
import 'package:lime/widgets/circular_clip.dart';
import 'package:lime/widgets/frosted_glas.dart';
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

  BuildContext _buildContext;
  StreamController<Map> _postStreamController;


  @override
  Widget build(BuildContext context) {

    _buildContext = context;

    Widget w;
    w = new LoadingListView<Map>(
        request, widgetAdapter: adapt, pageSize: widget.pageSize,
        pageThreshold: widget.pageThreshold, topStream: _postStreamController.stream,);


    Widget fab = new FeedActionButton(onPosted: onPosted,);


    w = new Scaffold(
      body: w,
      floatingActionButton: fab,
    );


    return w;
  }

  void onPosted(Map post){
    _postStreamController.add(post);
  }


  @override
  void initState() {
    super.initState();
    _postStreamController = new StreamController();
  }

  Future<List<Map>> request(int page, int pageSize) async {
    return lime.api.getFeed(paginationIndex: page, paginationSize: pageSize);
  }

  Widget adapt(Map map) {
    return new Post(map);
  }


}

class FeedActionButton extends StatefulWidget {

  final PostedCallback onPosted;

  FeedActionButton({this.onPosted});

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

  onPressed() async {
    Map post = await Navigator.of(_context).push(new _PostCreateRoute(_context));
    if(post != null && widget.onPosted!=null){
      this.widget.onPosted(post);
    }
  }
}

class _PostCreateRoute extends TransitionRoute with LocalHistoryRoute {

  final BuildContext context;

  bool dismissed = false;

  _PostCreateRoute(this.context);


  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    var overlay = new OverlayEntry(builder: (context) {
      Widget w;
      w = new AnimatedBuilder(animation: animation, builder: (context, widget) {
        Widget w = new PostCreate(onDismiss: onDismissed, onPosted: onPosted,);
        print("animation ${animation.value}");
        w = new Material(child: w, color: Colors.white.withOpacity(0.5),);
        w = new CircularClip(child: w, clip: animation.value,);
        w =
        new FrostedGlass(child: w, sigma: animation.value * 5.0, opacity: 0.0,);

        w = new DismissibleWrapper(child: w, direction: DismissDirection.down,
          onDismissed: (x) => onDismissed(),
          key: new Key("POST_CREATE"),);


        return w;
      });
      return w;
    },
        opaque: false,
        maintainState: true);

    return [overlay];
  }

  void onPosted(Map post){
    Navigator.of(context).pop(post);
  }

  void onDismissed() {
    this.controller.value=0.0;
    Navigator.of(context).pop();
  }

  // TODO: implement opaque
  @override
  bool get opaque => false;

  // TODO: implement transitionDuration
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}

