import 'package:lime/lime/api.dart';
import 'package:lime/misc/site.dart';
import 'package:pool/pool.dart';

Lime lime = new Lime();

class Lime {
  final LimeApi api = new LimeApi();
  final Site site = new Site(SiteSetting.STANDARD);
  static final Lime _lime = new Lime._internal();

  factory Lime(){
    return _lime;
  }

  Lime._internal();

  double distanceToKm(double distance) {
    return distance * 100;
  }
}

