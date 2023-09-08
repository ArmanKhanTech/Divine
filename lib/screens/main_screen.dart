import 'package:animations/animations.dart';
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
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.pink,
                ],
              ),
            ),
            padding: const EdgeInsets.only(
              top: 1
            ),
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              selectedLabelStyle: const TextStyle(fontSize: 0),
              unselectedLabelStyle: const TextStyle(fontSize: 0),
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.home),
                  activeIcon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Colors.pink,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.home,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.search),
                  activeIcon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink,
                        Colors.blue,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.search,
                    ),
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.play_circle),
                  activeIcon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink,
                        Colors.blue,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.play_circle_fill,
                    ),
                  ),
                  label: 'Reels',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.bell),
                  activeIcon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink,
                        Colors.blue,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.bell_fill,
                    ),
                  ),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.person),
                  activeIcon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink,
                        Colors.blue,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                    ),
                  ),
                  label: 'Profile',
                ),
              ],
              currentIndex: _page,
              unselectedIconTheme: const IconThemeData(size: 35, color: Colors.blue),
              selectedIconTheme: const IconThemeData(size: 35,),
              elevation: 0,
              onTap: (int index) {
                setState(() {
                  _page = index;
                });
              },
            ),
          )
        );
      },
      maximumSize: const Size(540.0, 960.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}