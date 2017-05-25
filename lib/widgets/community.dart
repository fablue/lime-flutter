import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/widgets/common.dart';
import 'package:lime/widgets/loading_list_view.dart';

class Community extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _CommunityState();
  }
}

class _CommunityState extends State<Community> {

  @override
  Widget build(BuildContext context) {
    return new LoadingListView<Map>(
        request,
        widgetAdapter: adapt

    );
  }

  Future<List<Map>> request(int page, int pageSize) async {
    return lime.api.getChannels(page: page, pageSize: pageSize);
  }

  Widget adapt(Map map) {
    return new CommunityMember(map);
  }
}

class CommunityMember extends StatelessWidget {

  final Map member;

  CommunityMember(this.member);

  @override
  Widget build(BuildContext context) {
    String channel = member["pseudo"];
    String name = member["realname"];
    int likes = member["likes"];

    Widget layer0;
    Widget layer2;

    print(lime.api.getLatestImage(channel));
    layer0 = new FadingImage.network(
        lime.api.getLatestImage(channel),
        fit: BoxFit.cover
    );


    Row row = new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new ClipOval(
              child: new FadingImage.network(
                  lime.api.getChannelImage(channel),
                  height: 75.0,
                  width: 75.0,
                  fit: BoxFit.cover
              )
          ),

          new Container(
              padding: new EdgeInsets.symmetric(horizontal: 12.0),
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new Text(
                        channel,
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    new Text(
                        name,
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400
                        )
                    ),
                    new Row(
                        children: [
                          new Container(
                              padding: new EdgeInsets.only(right: 8.0),
                              child:
                              new Image.asset(
                                "img/ghost_like_white.png",
                                width: 10.0,
                              )
                          ),
                          new Text(
                              member["likes"].toString(),
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400
                              )
                          )
                        ]

                    )
                  ]
              )
          )
        ]
    );


    layer2 = new Container(
        padding: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: row,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Color.lerp(Colors.transparent, Colors.black, 0.2),
                  Colors.transparent
                ]
            )
        )
    );

    Widget stack = new Stack(
        children: [
          layer0,
          layer2
        ],
        fit: StackFit.expand
    );

    Widget sizedBox = new SizedBox.fromSize(
        child: stack,
        size: new Size.fromHeight(300.0)
    );


    Container container = new Container(
        child: sizedBox,
        margin: new EdgeInsets.symmetric(vertical: 1.0)
    );

    Card card = new Card(
      child: container
    );

    return card;
  }
}