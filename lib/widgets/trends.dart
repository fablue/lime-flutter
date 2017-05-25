import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/widgets/loading_list_view.dart';
import 'package:lime/widgets/post.dart';

class Trends extends StatefulWidget {
  Trends({
    Key key
  }) : super(key:key) {
    print("new Trends");
  }


  @override
  State<StatefulWidget> createState() {
    print("Creating new TrendsState");
    return new _TrendsState();
  }

}

class _TrendsState extends State<Trends> {

  List <Map<String, dynamic>> posts = [];


  _TrendsState() {
    print("new TrendsState");
  }

  @override
  Widget build(BuildContext context) {
    return new LoadingListView<Map>(request,
    pageSize: -1, pageThreshold: -1,
    widgetAdapter: adapt);
  }


  Future<List<Map>> request(int page, int pageSize) async {
    if (page > 0)
      return [];
    else
      return await lime.api.getTrends();
  }


  Widget adapt(Map map){
    return new Post(map);
  }

}