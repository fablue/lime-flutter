import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PagePost extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _PagePostState();
  }
}

class _PagePostState extends State<PagePost> {

  File imageFile;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new ImagePreview(imageFile),
              new Row(
                  children: [
                    new IconButton(
                        icon: new Icon(Icons.image), onPressed: selectImage)
                    ,
                    new Expanded(
                        child: new TextField(
                          maxLines: 7,
                          keyboardType: TextInputType.text
                        )
                    ),

                    new IconButton(
                        icon: new Icon(Icons.done),
                        onPressed: () => print("sending.."))
                  ]
              )
            ]
        )
    );
  }

  Future selectImage() async {
    File file = await ImagePicker.pickImage();
    mounted ? this.setState(() => this.imageFile = file) : null;
  }
}

class ImagePreview extends StatelessWidget {

  final File imageFile;

  ImagePreview(this.imageFile);

  @override
  Widget build(BuildContext context) {
    if (this.imageFile == null) return new Container();

    return  new Expanded(
        child: new Container(
          padding: const EdgeInsets.all(8.0),
          child: new Image.file(this.imageFile)
        )
    );
  }
}