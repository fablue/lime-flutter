import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lime/lime/lime.dart';
import 'package:lime/misc/utils.dart';

class PostCreate extends StatefulWidget {

  final VoidCallback onDismiss;

  PostCreate({
    this.onDismiss
  });

  @override
  State<StatefulWidget> createState() {
    return new _PostCreateState();
  }
}

class _PostCreateState extends State<PostCreate> {

  File _file;
  String _text;

  @override
  Widget build(BuildContext context) {
    return new Column(
        children: [
          new _Header(this),
          new _Body(this),
          new _Footer(this)
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween
    );
  }

  set image(File file) {
    this._file = file;
  }

  set text(String text) {
    this._text = text;
  }

  Future onPost() async {
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

  // Map response = await lime.api.postMessage(
    //   text: _text, compressedImage: image);
   // print(response);
  }

  void dismiss() {

  }
}


class _Header extends StatelessWidget {

  final _PostCreateState _postCreateState;

  _Header(this._postCreateState);

  @override
  Widget build(BuildContext context) {
    Widget child = new Row(
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

    child = new Stack(
        alignment: FractionalOffset.center,
        children: [
          child,
          new Center(
              child: new Icon(Icons.drag_handle)
          )
        ]
    );

    child = new Container(
        margin: const EdgeInsets.only(top: 25.0),
        child: child
    );

    return child;
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

      Widget stack0 = new Text(
          "Swipe up to dismiss",
          style: new TextStyle(
              fontWeight: FontWeight.w300,
              color: Theme
                  .of(context)
                  .primaryColor
          )
      );


      Widget stack1 = child;


      child = new Stack(
          children: [
            stack0, stack1
          ],
          alignment: new FractionalOffset(0.5, 0.8)
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
    return new Container(
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
  }
}