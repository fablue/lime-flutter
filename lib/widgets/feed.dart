import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/widgets/loading_list_view.dart';
import 'package:lime/widgets/post.dart';

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


  @override
  Widget build(BuildContext context) {
    return new LoadingListView<Map>(
        request, widgetAdapter: adapt, pageSize: widget.pageSize,
        pageThreshold: widget.pageThreshold);
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
}