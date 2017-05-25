import 'package:lime/lime/api.dart';

Lime lime = new Lime();

class Lime{
  final LimeApi api = new LimeApi();
  static final Lime _lime = new Lime._internal();
  factory Lime(){
    return _lime;
  }
  Lime._internal();

  double distanceToKm(double distance){
    return distance * 100;
  }
}

