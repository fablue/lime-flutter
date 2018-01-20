import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/misc/notifications.dart';
import 'package:lime/widgets/common.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> post;
  final double paddingH = 8.0;
  final Duration queryInterval;

  Post(this.post, {
    Key key,
    this.queryInterval: const Duration(seconds: 2)
  }) : super(key: new Key(post["id"].toString()));

  @override
  State<StatefulWidget> createState() {
    return new PostState();
  }


}

class PostState extends State<Post> {

  Timer timer;
  BuildContext buildContext;


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void startTimer() {
    if (!mounted) return;
    if (timer != null) timer.cancel();
    timer = new Timer(widget.queryInterval, query);
  }

  Future query() async {
    if (!mounted) return;

    Map post = await lime.api.getMessage(widget.post["id"]).catchError((error) {
      return null;
    });

    if (post != null) {
      if (mounted) {
        new ListElementUpdate<Map>(widget.post["id"], post);
      }
    }

    startTimer();
  }

  bool contains(String key) {
    return widget.post[key] != null;
  }

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    buildContext = context;


    Container container = new Container(
        margin: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        padding: const EdgeInsets.symmetric(
            horizontal: 2.0, vertical: 6.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                  padding: new EdgeInsets.symmetric(
                      horizontal: widget.paddingH),
                  child: new PostHeaderWidget(widget.post)
              ),
              contains("mediaUrl")
                  ? new PostImageWidget(widget.post)
                  : null,
              new Container(
                  padding: new EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: widget.paddingH),
                  child: new Text(widget.post["message"] != null
                      ? widget.post["message"]
                      : "")),

              new PostInteraction(widget.post),
              new LastComments(widget.post)

            ].where(notNull).toList()

        )

    );

    Card card = new Card(
        color: Colors.white,
        child: container
    );

    return card;
  }
}


class PostHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  PostHeaderWidget(this.post);

  String getChannelImage() {
    String imageRaw = post["channelImage"];
    return imageRaw != null ? lime.api.getMediaUrl(imageRaw) : null;
  }

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        post["channelImage"] != null
            ? new ClipOval(
            child: new Container(
                width: 50.0,
                height: 50.0,
                child: new FadingImage.network(
                    lime.api.getChannelImage(post["channel"]),
                    fit: BoxFit.cover)))
            : null,
        new Expanded(
            child: new Container(
                padding: new EdgeInsets.symmetric(horizontal: 12.0),
                child: new Column(
                    children: [
                      new Text(post["channel"] ?? "",
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                      new Text(post["realName"] ?? "",
                          style: new TextStyle(fontSize: 12.0)),

                      new PostLocationWidget(post)
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start))),
        new Container(
            alignment: FractionalOffset.centerRight,
            padding: new EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(children: [
              new Text("16:09",
                  style: new TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.w300)),
              new Text("05.05",
                  style: new TextStyle(
                      fontSize: 10.0, fontWeight: FontWeight.w300))
            ])),
        new FractionalTranslation(
            child: new PopupMenuButton(
                itemBuilder: (_) =>
                <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      child: const Text('löschen'), value: 'delete'),
                  new PopupMenuItem<String>(
                      child: const Text('melden'), value: 'report'),
                ],
                elevation: 8.0),
            translation: new Offset(0.0, -0.25))
      ].where(notNull).toList(),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }
}


class PostLocationWidget extends StatelessWidget {

  final Map post;

  PostLocationWidget(this.post);

  @override
  Widget build(BuildContext context) {
    double distance = post["distance"];
    String city = post["city"];

    if (distance == null && city == null) {
      return new Container();
    }

    double km = distance != null ? lime.distanceToKm(distance) : null;


    String display;

    if (km == null || (km > 30.0 && city != null)) {
      display = city;
    } else {
      display = "${km.toStringAsFixed(1)} km";
    }

    return new Text(
        display,
        style: new TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w300
        )
    );
  }
}

class PostImageWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  double getAspectRatio() {
    var arRaw = post["aspectRatio"];
    if (arRaw != null) {
      double ratio = arRaw;
      if (ratio > 1.2) return 1 / 1.2;
      if (ratio < 0.2) return 1 / 0.2;
      return 1 / ratio;
    }
    return 1.0;
  }

  String getImage() {
    String imageRaw = post["mediaUrl"];
    return imageRaw != null ? lime.api.getMediaUrl(imageRaw) : null;
  }

  PostImageWidget(this.post);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
        aspectRatio: getAspectRatio(),
        child: new Container(
            padding: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: new FadingImage.network(getImage(), fit: BoxFit.cover)
        ));
  }

}


class PostInteraction extends StatefulWidget {


  final Map<String, dynamic> post;

  PostInteraction(this.post);

  @override
  State<StatefulWidget> createState() {
    return new _PostInteractionState();
  }
}


class _PostInteractionState extends State<PostInteraction> {

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.symmetric(horizontal: 8.0),
        child:
        new Row(
            children: [
              new GhostLike(
                  like: widget.post["liked"],
                  limeLikeCallback: likeCallback
              ),
              new Expanded(
                  child: new LikingChannels(widget.post["channelsLiking"])
              ),
              new IconButton(
                  icon: new Icon(
                      Icons.chat_bubble_outline,
                      size: 25.0,
                      color: Colors.grey
                  ),
                  onPressed: () {
                    print("Chat pressed");
                  }
              )
            ]
        )
    );
  }

  void likeCallback(bool like) {
    like ? lime.api.putVote(widget.post["id"]) :
    lime.api.deleteVote(widget.post["id"]);
    setState(() {
      List<String> channels = widget.post["channelsLiking"];
      channels.remove(lime.api.channel);
      if (like) channels.insert(0, lime.api.channel);
      widget.post["liked"] = like;
    });
  }
}


class GhostLike extends StatefulWidget {


  final bool like;
  final LimeLikeCallback limeLikeCallback;

  GhostLike({
    this.like: false,
    this.limeLikeCallback: null
  });


  @override
  State<StatefulWidget> createState() {
    return new _GhostLikeState();
  }
}

class _GhostLikeState extends State<GhostLike>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  Curve scaleCurve;
  double likeAlpha = 0.0;
  double scale = 1.0;


  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
        child: new InkResponse(
            child: new FractionallySizedBox(
                child: buildGhost(context),
                heightFactor: scale
            ),
            onTap: onTap
        ),
        constraints: new BoxConstraints(
            maxHeight: 25.0
        )
    );
  }

  Widget buildGhost(BuildContext context) {
    return new FractionallySizedBox(
      child: new Image.asset
        (
        "img/ghost_like_white.png",
        color: Color.lerp(Colors.grey, Theme
            .of(context)
            .primaryColor, likeAlpha),
        colorBlendMode: BlendMode.srcATop,
      ),

    );
  }


  void onTap() {
    if (widget.limeLikeCallback != null) {
      widget.limeLikeCallback(controller.value < 0.5);
    }
  }


  @override
  void initState() {
    super.initState();

    scaleCurve = new BoomerangCurve(child: Curves.bounceInOut);
    controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..addListener(() {
        setState(() {
          scale = scaleCurve.transform(controller.value);
          likeAlpha = controller.value;
        });
      });

    controller.value = widget.like ? 1.0 : 0.0;
  }


  @override
  void didUpdateWidget(GhostLike oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.like) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }


}


typedef LimeLikeCallback(bool like);


class LikingChannels extends StatefulWidget {

  final List<String> channels;

  LikingChannels(this.channels);

  @override
  State<StatefulWidget> createState() {
    return new _LikingChannelsState();
  }
}


class _LikingChannelsState extends State<LikingChannels> {

  @override
  Widget build(BuildContext context) {
    return new Row(
        children: [
          new Container(
              padding: new EdgeInsets.only(left: 8.0, right: 4.0),
              child: new Text(
                  widget.channels!=null?(widget.channels?.length.toString()) ?? "" : 0.toString(),
                  style: new TextStyle(
                      fontWeight: FontWeight.w300
                  )
              )
          ),

          new Container(
              child: new Text(
                  buildDisplayString(),
                  style: new TextStyle(
                      fontWeight: FontWeight.w500
                  ),
                  overflow: TextOverflow.ellipsis
              ),
              padding: new EdgeInsets.only(right: 8.0)
          )
        ]
    );
  }

  String buildDisplayString() {
    String build = "";
    bool first = true;
    widget.channels?.forEach((String channel) {
      build = "$build${!first ? "," : ""} $channel";
      first = false;
    });
    return build;
  }

  @override
  void didUpdateWidget(LikingChannels oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}


class LastComments extends StatefulWidget {

  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> lastComments;
  final int comments;

  LastComments(this.post)
      : lastComments = post["lastComments"],
        comments = post["comments"];

  @override
  State<StatefulWidget> createState() {
    return new _LastCommentsState();
  }
}

class _LastCommentsState extends State<LastComments> {

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: new RichText(text: getCommentsSpan(context))
    );
  }

  TextSpan getCommentsSpan(BuildContext context) {
    var innerF = () {
      List<TextSpan> list = new List();

      int furtherComments = widget.comments??0 - widget.lastComments?.length??0;
      if (furtherComments > 0) {
        list.add(
            new TextSpan(
                text: "... $furtherComments previous answers\n",
                style: new TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300
                )
            )
        );
      }

      widget.lastComments?.forEach(
              (comment) {
            list.add(
                new TextSpan(
                    text: "${comment["channel"]} ",
                    style: new TextStyle(
                        fontWeight: FontWeight.w400
                    )
                )
            );

            list.add(
                new TextSpan(
                    text: "${comment["message"]}\n",
                    style: new TextStyle(
                        fontWeight: FontWeight.w300
                    )
                )
            );
          }
      );

      return list;
    };

    return new TextSpan(
        children: innerF(),
        style: Theme
            .of(context)
            .textTheme
            .body2
    );
  }

  List<Widget> comments(BuildContext context) {
    List<Widget> list = new List();
    widget.lastComments.forEach((comment) {
      TextSpan channelSpan = new TextSpan(
          text: "${comment["channel"]} ",
          style: new TextStyle(
            fontWeight: FontWeight.w400,
          )
      );

      TextSpan messageSpan = new TextSpan(
          text: comment["message"],
          style: new TextStyle(
              fontWeight: FontWeight.w300
          )
      );

      TextSpan finalSpan = new TextSpan(
          children: [
            channelSpan,
            messageSpan
          ],
          style: Theme
              .of(context)
              .textTheme
              .body2
      );

      list.add(
          new RichText(
              text: finalSpan,
              textAlign: TextAlign.left
          )
      );
    });

    return list;
  }
}

