import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../module/chats/chat_screen.dart';
import '../model/post_model.dart';
import '../model/user_model.dart';
import '../utility/choose_upload.dart';
import '../utility/constants.dart';
import '../utility/firebase.dart';
import '../viewmodel/user/story_view_model.dart';
import '../widget/story_widget.dart';
import '../widget/user_post.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({
    super.key,
  });

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>
    with AutomaticKeepAliveClientMixin<FeedsPage> {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final scrollKey = GlobalKey();

  List<DocumentSnapshot> posts = [];
  List<DocumentSnapshot> suggested = [];

  List<String> followingAccounts = [];
  List<String> hashTags = [];

  int pagePosts = 0, pageSuggested = 0;

  bool loadingMorePosts = false, loadingMoreSuggested = false;
  bool loadedPosts = false, loadedSuggested = false;

  final ScrollController scrollController = ScrollController();

  late QuerySnapshot querySnapshot;

  Future<void> loadMorePosts() async {
    setState(() {
      loadingMorePosts = true;
      if (followingAccounts.isNotEmpty) {
        pagePosts += 3;
      }
    });

    if (followingAccounts.isNotEmpty) {
      if (followingAccounts.length < 30) {
        if (posts.isNotEmpty) {
          querySnapshot = await postRef
              .where('ownerId', whereIn: followingAccounts)
              .orderBy('timestamp', descending: true)
              .startAfterDocument(posts.last)
              .limit(pagePosts)
              .get();
        } else {
          querySnapshot = await postRef
              .where('ownerId', whereIn: followingAccounts)
              .orderBy('timestamp', descending: true)
              .limit(pagePosts)
              .get();
        }
      } else {
        for (int i = 0; i < followingAccounts.length; i += 30) {
          if (posts.isNotEmpty) {
            querySnapshot = await postRef
                .where('ownerId',
                    whereIn: followingAccounts.skip(i).take(30).toList())
                .orderBy('timestamp', descending: true)
                .startAfterDocument(posts.last)
                .limit(pagePosts)
                .get();
          } else {
            querySnapshot = await postRef
                .where('ownerId',
                    whereIn: followingAccounts.skip(i).take(30).toList())
                .orderBy('timestamp', descending: true)
                .limit(pagePosts)
                .get();
          }
        }
      }
    } else {
      setState(() {
        loadingMorePosts = false;
        loadedPosts = true;
        getHashTags();
      });
      return;
    }

    setState(() {
      if (querySnapshot.docs.length < pagePosts || querySnapshot.docs.isEmpty) {
        loadedPosts = true;
        getHashTags();
        return;
      } else {
        posts.addAll(querySnapshot.docs);
      }
      loadingMorePosts = false;
    });
  }

  Future<void> loadMoreSuggested() async {
    setState(() {
      loadingMoreSuggested = true;
      pageSuggested += 3;
    });

    if (suggested.isNotEmpty) {
      querySnapshot = await postRef
          .where('hashtags',
              arrayContainsAny:
                  hashTags.take(hashTags.length > 10 ? 10 : hashTags.length))
          .orderBy('timestamp', descending: true)
          .startAfterDocument(suggested.last)
          .limit(pageSuggested)
          .get();
    } else {
      querySnapshot = await postRef
          .where('hashtags',
              arrayContainsAny:
                  hashTags.take(hashTags.length > 10 ? 10 : hashTags.length))
          .orderBy('timestamp', descending: true)
          .limit(pageSuggested)
          .get();
    }

    setState(() {
      if (querySnapshot.docs.length < pageSuggested ||
          querySnapshot.docs.isEmpty) {
        loadedSuggested = true;
      } else {
        suggested.addAll(querySnapshot.docs);
      }
      loadingMoreSuggested = false;
    });
  }

  Future<void> getFollowingAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    followingAccounts = prefs.getStringList('followingAccounts')!;

    if (followingAccounts.isEmpty) {
      QuerySnapshot snapshot = await followingRef
          .doc(auth.currentUser!.uid)
          .collection('userFollowing')
          .get();
      for (var doc in snapshot.docs) {
        followingAccounts.add(doc.id);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('followingAccounts', followingAccounts);
      print(followingAccounts);
    }
    loadMorePosts();
  }

  Future<void> getHashTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hashTags = prefs.getStringList('hashTags')!;

    if (hashTags.isEmpty) {
      DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
      UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      var mapEntries = user.userHashtags!.entries.toList()
        ..sort((b, a) => a.value.compareTo(b.value));
      for (var entry in mapEntries) {
        hashTags.add(entry.key);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('hashTags');
      prefs.setStringList('hashTags', hashTags);
      print(hashTags);
    }
    loadMoreSuggested();
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !loadingMorePosts &&
          !loadingMoreSuggested &&
          posts.isNotEmpty) {
        if (!loadedPosts) {
          loadMorePosts();
        } else if (!loadedSuggested) {
          loadMoreSuggested();
        }
        return;
      }
    });

    initUserData();
  }

  Future<void> initUserData() async {
    await getFollowingAccounts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        systemOverlayStyle:
            Theme.of(context).colorScheme.background != Colors.black
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.dark,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  )
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.light,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
        surfaceTintColor: Colors.transparent,
        title: GradientText(
          Constants.appName,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.ubuntu().fontFamily,
          ),
          colors: const [Colors.blue, Colors.pink, Colors.purple],
        ),
        actions: [
          IconButton(
              icon: const Icon(
                CupertinoIcons.add_circled,
                size: 30.0,
              ),
              onPressed: () => {
                    chooseUpload(context, viewModel),
                  }),
          IconButton(
            icon: const Icon(
              CupertinoIcons.chat_bubble,
              size: 30.0,
            ),
            padding: const EdgeInsets.only(
              right: 10.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      extendBody: false,
      body: RefreshIndicator(
        color: Colors.purple,
        onRefresh: () async {
          setState(() {
            posts.clear();
            suggested.clear();
            pagePosts = 0;
            pageSuggested = 0;
            loadedPosts = false;
            loadedSuggested = false;
          });
          await loadMorePosts();
          return Future.delayed(const Duration(seconds: 2));
        },
        displacement: 50,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(
                height: 135,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: StoryWidget()),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              SizedBox(
                height: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.purple,
                        Colors.pink,
                        Colors.blue,
                      ],
                    ),
                  ),
                ),
              ),
              if (posts.isEmpty && suggested.isEmpty && !loadedPosts)
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const SizedBox(),
                ),
              // TODO: Populate reels and threads too.
              followingAccounts.isNotEmpty && !loadedPosts
                  ? Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, index) {
                            PostModel model = PostModel.fromJson(
                                posts[index].data() as Map<String, dynamic>);
                            return UserPost(post: model, index: index);
                          },
                        )
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.only(
                        top: 15.0,
                      ),
                      child: Center(
                        child: Text(
                          'Follow some accounts to see their posts.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
              // TODO: Fix it (not visible)
              if (loadingMorePosts)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                      bottom: 20.0,
                    ),
                    child: SpinKitWave(
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ),
              hashTags.isNotEmpty && loadedPosts
                  ? Column(
                      children: [
                        posts.isNotEmpty
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.check_mark_circled_solid,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'You have all caught up.',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Suggested Posts',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggested.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (context, index) {
                            PostModel model = PostModel.fromJson(
                                suggested[index].data()
                                    as Map<String, dynamic>);
                            if (followingAccounts.contains(model.ownerId)) {
                              return const SizedBox();
                            } else {
                              return UserPost(post: model, index: index);
                            }
                          },
                        )
                      ],
                    )
                  : loadedSuggested
                      ? const Padding(
                          padding: EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                          ),
                          child: Center(
                            child: Text(
                              'No more posts to show.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
              if (loadingMoreSuggested)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                      bottom: 20.0,
                    ),
                    child: SpinKitCubeGrid(
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
