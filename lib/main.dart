import 'package:flutter/material.dart';
import 'package:lime/lime//lime.dart';
import 'package:lime/widgets/community.dart';
import 'package:lime/widgets/feed.dart';
import 'package:lime/widgets/trends.dart';


void main() {
  runApp(new LimeApp());
}

/// Returns the color scheme used by lime
MaterialColor limeColor() {
  return new MaterialColor(0xFF0498C1, {
    50: new Color(0xFFE1F3F8),
    100: new Color(0xFFB4E0EC),
    200: new Color(0xFF82CCE0),
    300: new Color(0xFF4FB7D4),
    400: new Color(0xFF2AA7CA),
    500: new Color(0xFF0498C1),
    600: new Color(0xFF0390BB),
    700: new Color(0xFF0385B3),
    800: new Color(0xFF027BAB),
    900: new Color(0xFF016A9E)
  });
}

class LimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Lime lime = new Lime();
    return new MaterialApp(
      title: 'Lime',
      theme: new ThemeData(
          primarySwatch: limeColor(),
          scaffoldBackgroundColor: Colors.white,
          primaryColor: limeColor(), backgroundColor: Colors.white),
      home: new MainPage(lime),
      showPerformanceOverlay: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final Lime lime;

  MainPage(this.lime);


  @override
  State<StatefulWidget> createState() {
    return new _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {

  PageController pageController;
  int page = 1;

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        backgroundColor: Colors.white,
        body: new PageView(
            children: [
              new Trends(key: new Key("TRENDS")),
              new Feed(key: new Key("FEED")),
              new Community()
            ],
            controller: pageController,
            onPageChanged: onPageChanged
        ),
        bottomNavigationBar: new BottomNavigationBar(
            items: [
              new BottomNavigationBarItem(
                icon: new Icon(new IconData(62008, fontFamily: "mdi")),
                title: new Text("trends"),
              ),
              new BottomNavigationBarItem(
                  icon: new Icon(Icons.location_on), title: new Text("feed")),
              new BottomNavigationBarItem(
                  icon: new Icon(Icons.people), title: new Text("community"))
            ],
            onTap: onTap,
            currentIndex: page
        )
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController(initialPage: this.page);
  }


  void onTap(int index) {
    pageController.animateToPage(
        index, duration: const Duration(milliseconds: 300),
        curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this.page = page;
    });
  }


}
