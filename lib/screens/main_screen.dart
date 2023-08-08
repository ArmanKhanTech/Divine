import 'package:animations/animations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import '../pages/activity_page.dart';
import '../pages/feeds_page.dart';
import '../pages/profile_page.dart';
import '../pages/reels_page.dart';
import '../pages/search_page.dart';
import '../utilities/firebase.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  int _page = 0;

  List pages = [
    {
      'title': 'Home',
      'page': const FeedsPage(),
      'index': 0,
    },
    {
      'title': 'Search',
      'page': const SearchPage(),
      'index': 1,
    },
    {
      'title': 'Reels',
      'page': const ReelsPage(),
      'index': 2,
    },
    {
      'title': 'Notification',
      'page': const ActivityPage(),
      'index': 3,
    },
    {
      'title': 'Profile',
      'page': ProfilePage(profileId: auth.currentUser!.uid),
      'index': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {

    return FlutterWebFrame(
      builder: (context) {

        return Scaffold(
          body: PageTransitionSwitcher(
            transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                ) {

              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: pages[_page]['page'],
          ),
          // Navigation Bar.
          bottomNavigationBar: CurvedNavigationBar(
            index: 0,
            height: kIsWeb != true ? 50.0 : 60.0,
            items: <Widget>[
              Icon((_page == 0) ? CupertinoIcons.house_fill : CupertinoIcons.house, size: 30, color: (_page == 0) ? Colors.white : Colors.blue,),
              Icon((_page == 1) ? CupertinoIcons.search : CupertinoIcons.search, size: 30, color: (_page == 1) ? Colors.white : Colors.blue,),
              Icon((_page == 2) ? CupertinoIcons.play_circle_fill : CupertinoIcons.play_circle, size: 30, color: (_page == 2) ? Colors.white : Colors.blue,),
              Icon((_page == 3) ? CupertinoIcons.bell_fill : CupertinoIcons.bell, size: 30, color: (_page == 3) ? Colors.white : Colors.blue,),
              Icon((_page == 4) ? CupertinoIcons.person_fill : CupertinoIcons.person, size: 30, color: (_page == 4) ? Colors.white : Colors.blue,),
            ],
            color: Theme.of(context).colorScheme.background,
            buttonBackgroundColor: Colors.pink,
            backgroundColor: Colors.blue,
            animationCurve: Curves.easeIn,
            animationDuration: const Duration(milliseconds: 500),
            onTap: (index) {
              setState(() {
                _page = index;
              });
            },
            letIndexChange: (index) => true,
          ),
        );
      },
      maximumSize: const Size(500.0, 825.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}