import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

import '../tab/activity_tab.dart';
import '../tab/feeds_tab.dart';
import '../tab/profile_tab.dart';
import '../tab/reels_tab.dart';
import '../tab/search_tab.dart';

import '../../../utility/firebase.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> pages;
  late PageController pageController;
  late int page;

  @override
  void initState() {
    super.initState();

    page = 0;
    pages = [
      const FeedTab(),
      const SearchTab(),
      const ReelsTab(),
      const ActivityTab(),
      ProfileTab(profileId: auth.currentUser!.uid),
    ];
    pageController = PageController(initialPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
      builder: (context) {
        return Scaffold(
            body: PageView(
              controller: pageController,
              children: pages,
            ),
            extendBody: false,
            extendBodyBehindAppBar: false,
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
              padding: const EdgeInsets.only(top: 1),
              child: BottomNavigationBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
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
                currentIndex: page,
                unselectedIconTheme:
                    const IconThemeData(size: 35, color: Colors.blue),
                selectedIconTheme: const IconThemeData(
                  size: 35,
                ),
                elevation: 0,
                onTap: (int index) {
                  setState(() {
                    page = index;
                    pageController.jumpToPage(page);
                  });
                },
              ),
            ));
      },
      enabled: kIsWeb,
      maximumSize: const Size(540.0, 960.0),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
