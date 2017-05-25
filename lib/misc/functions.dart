import 'dart:async';

import 'package:flutter/widgets.dart';


typedef Future<List<T>> PageRequest<T> (int page, int pageSize);
typedef Future<List<Map>> ApiPageRequest(int page, int pageSize);
typedef void PaginationThresholdCallback();
typedef Widget WidgetAdapter<T>(T t);
typedef int Indexer<T>(T t);
