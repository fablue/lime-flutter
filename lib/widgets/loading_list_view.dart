import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/misc/functions.dart';
import 'package:lime/misc/notifications.dart';
import 'package:meta/meta.dart';

class LoadingListView<T> extends StatefulWidget {

  final PageRequest<T> pageRequest;
  final int pageSize;
  final int pageThreshold;
  final WidgetAdapter<T> widgetAdapter;
  final bool reverse;
  final Indexer<T> indexer;

  /// New elements will appear at the start
  final Stream<T> topStream;

  LoadingListView(this.pageRequest, {
    this.pageSize: 50,
    this.pageThreshold:10,
    @required this.widgetAdapter: null,
    this.reverse: false,
    this.indexer,
    this.topStream
  });

  @override
  State<StatefulWidget> createState() {
    return new _LoadingListViewState();
  }
}


class _LoadingListViewState<T> extends State<LoadingListView<T>> {

  List<T> objects = [];
  Map<int, int> index = {};
  Future request;

  @override
  Widget build(BuildContext context) {
    ListView listView = new ListView.builder(
        itemBuilder: itemBuilder,
        itemCount: objects.length,
        reverse: widget.reverse
    );

    RefreshIndicator refreshIndicator = new RefreshIndicator(
        onRefresh: onRefresh,
        child: listView
    );

    return new NotificationListener<ListElementUpdate<T>>(
        child: refreshIndicator,
        onNotification: onUpdate);
  }

  @override
  void initState() {
    super.initState();
    this.lockedLoadNext();
    if(widget.topStream!=null){
      widget.topStream.listen((T t){
        setState((){
          this.objects.insert(0, t);
          this.reIndex();
        });
      });
    }
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index + widget.pageThreshold > objects.length) {
      notifyThreshold();
    }

    return widget.widgetAdapter != null ? widget.widgetAdapter(objects[index])
        : new Container();
  }


  void notifyThreshold() {
    lockedLoadNext();
  }

  bool onUpdate(ListElementUpdate<T> update) {
    if (widget.indexer == null) {
      debugPrint("ListElementUpdate on un-indexed list");
      return false;
    }

    int index = this.index[update.key];
    if (index == null) {
      debugPrint("ListElementUpdate index not found");
      return false;
    }

    setState(() {
      this.objects[index] = update.instance;
    });
    return true;
  }

  Future onRefresh() async {
    this.request?.timeout(const Duration());
    List<T> fetched = await widget.pageRequest(0, widget.pageSize);
    setState(() {
      this.objects.clear();
      this.index.clear();
      this.addObjects(fetched);
    });

    return true;
  }

  void lockedLoadNext() {
    if (this.request == null) {
      this.request = loadNext().then((x) {
        this.request = null;
      });
    }
  }

  Future loadNext() async {
    int page = (objects.length / widget.pageSize).floor();
    List<T> fetched = await widget.pageRequest(page, widget.pageSize);

    if(mounted) {
      this.setState(() {
        addObjects(fetched);
      });
    }
  }


  void addObjects(Iterable<T> objects) {
    objects.forEach((T object) {
      int index = this.objects.length;
      this.objects.add(object);
      if (widget.indexer != null) {
        this.index[widget.indexer(object)] = index;
      }
    });
  }

  void reIndex(){
    this.index .clear();
    if(widget.indexer!=null){
      int i = 0;
      this.objects.forEach((object){
        index[widget.indexer(object)] == i;
        i++;
      });
    }
  }
}


