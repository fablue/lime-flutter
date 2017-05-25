import 'package:flutter/widgets.dart';

class ListElementUpdate<T> extends Notification{
  final int key;
  final T instance;

  ListElementUpdate(this.key, this.instance);
}