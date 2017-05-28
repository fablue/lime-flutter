import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PostCreate extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _PostCreateState();
  }
}

class _PostCreateState extends State<PostCreate> {

  @override
  Widget build(BuildContext context) {
    return new Column(
        children: [
          new Container(
        padding: const EdgeInsets.all(16.0)
            ,
              child: new Row(
                  children: [
                    new Expanded(
                        child: new TextField(
                            maxLines: 7,
                            decoration: new InputDecoration(
                                labelText: "Message"
                            )
                        )
                    )
                  ]
              ))
        ],
        mainAxisAlignment: MainAxisAlignment.end
    );
  }
}