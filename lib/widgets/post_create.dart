import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/misc/utils.dart';
import 'package:lime/widgets/frosted_glas.dart';

typedef void PostedCallback(Map posting);

class PostCreate extends StatefulWidget {

  final VoidCallback onDismiss;
  final PostedCallback onPosted;

  PostCreate({
    this.onDismiss,
    this.onPosted
  });

  @override
  State<StatefulWidget> createState() {
    return new _PostCreateState();
  }
}

class _PostCreateState extends State<PostCreate>
    with SingleTickerProviderStateMixin {

  /// Any currently picked image file to display
  File _file;

  /// The text currently entered
  String _text;

  /// Indicating whether or not the
  /// user is currently sending the post
  /// to the server and is waiting for any
  /// response.
  bool _posting = false;

  /// Animation which should display
  /// a transition from normal state (=0) 
  /// to posting state (=1)
  Animation _postingAnimation;
  AnimationController _postingAnimationController;

  @override
  Widget build(BuildContext context) {
    Widget w = new Column(
        children: [
          new _Header(this),
          new _Body(this),
          new _Footer(this)
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween
    );

    w = new IgnorePointer(ignoring: _posting, child: w,);
    return w;
  }

  set image(File file) {
    this._file = file;
  }

  set text(String text) {
    this._text = text;
  }

  Future onPost() async {
    this.setState(() => this._posting = true);
    this._postingAnimationController.forward();

    try {
      print("Postinng image: $_file with text: $_text");
      List<int> image;
      if (_file != null) {
        int size = await _file.length();
        image = await lime.site.commission(
            ImageUtil.compressImage,
            positionalArgs: [_file]
        );
        print("Compression done: first $size then ${image.length}");
      }

      Map response = await lime.api.postMessage(
          text: _text, compressedImage: image);

      if(widget.onPosted!=null){
        widget.onPosted(response);
      }

    } catch (e) {
      print("Posting failed: $e");
      this._postingAnimationController.reverse();
    }
    finally {
      this.setState(() => this._posting = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _postingAnimationController =
    new AnimationController(
        vsync: this, duration: const Duration(seconds: 1), value: 0.0);
    _postingAnimation = new CurvedAnimation(
        parent: _postingAnimationController, curve: Curves.ease);
    _postingAnimation.addListener(() => this.setState(() {}));
  }

}


class _Header extends StatelessWidget {

  final _PostCreateState _postCreateState;

  _Header(this._postCreateState);

  @override
  Widget build(BuildContext context) {
    Widget w;
    w = new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new IconButton(
              icon: new Icon(
                  Icons.arrow_drop_down,
                  color: Theme
                      .of(context)
                      .iconTheme
                      .color
              ),
              onPressed: null
          ),
          new FlatButton(
            onPressed: _postCreateState.onPost,
            child: new Text(
                "POST",
                style: new TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor
                )
            ),
            splashColor: Theme
                .of(context)
                .primaryColor,

          )
        ]
    );

    w = new Stack(
        alignment: FractionalOffset.center,
        children: [
          w,
          new Center(
              child: new Icon(Icons.drag_handle)
          )
        ]
    );

    w = new Container(
      margin: const EdgeInsets.only(top: 25.0),
      child: w,
    );

    return new FractionalTranslation(translation: new Offset(
        0.0, -_postCreateState._postingAnimation.value), child: w,);
  }


}

class _Body extends StatefulWidget {

  final _PostCreateState _postCreateState;

  _Body(this._postCreateState);

  @override
  State<StatefulWidget> createState() {
    return new _BodyState();
  }
}

class _BodyState extends State<_Body> {

  File image;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (image == null) {
      child = new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new IconButton(
                icon: new Icon(Icons.photo_camera),
                onPressed: pickImage
            ),
            new SizedBox(width: 50.0),
            new IconButton(
                icon: new Icon(Icons.photo),
                onPressed: pickImage
            )
          ]
      );
    } else {
      child = new Image.file(image);
      child = new Material(
          child: child,
          borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
          elevation: 5.0

      );


      child = new Dismissible(
          key: new ObjectKey(image),
          child: child,
          direction: DismissDirection.up,
          onDismissed: (direction) {
            setState(() => this.image = null);
          },
          resizeDuration: const Duration(milliseconds: 1)
      );


      List<Widget> stacked = [];
      stacked.add(child);


      if (widget._postCreateState._posting) {
        Widget w;
        w = new LinearProgressIndicator();
        stacked.add(w);
      }

      child = new Stack(
        children: stacked,
        alignment: FractionalOffset.bottomCenter,
        fit: StackFit.loose,
      );

      child = new Container(
          child: child,
          margin: const EdgeInsets.all(10.0)
      );
    }

    return new Flexible(child: child);
  }

  @override
  void initState() {
    super.initState();
    this.widget._postCreateState._postingAnimation.addListener(() =>
        this.setState(() {}));
  }

  Future pickImage() async {
    var image = await ImagePicker.pickImage();
    widget._postCreateState.image = image;
    setState(() {
      this.image = image;
    });
  }
}

class _Footer extends StatelessWidget {

  final _PostCreateState _postCreateState;

  _Footer(this._postCreateState);

  @override
  Widget build(BuildContext context) {
    Widget w = new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
            children: [
              new Expanded(
                  child: new TextField(
                      maxLines: 7,
                      decoration: new InputDecoration(
                          labelText: "Message"
                      ),
                      onChanged: (String text) => _postCreateState.text = text
                  )
              )
            ]
        )
    );

    w = new FractionalTranslation(translation: new Offset(
        0.0, _postCreateState._postingAnimation.value), child: w,);

    return w;
  }
}