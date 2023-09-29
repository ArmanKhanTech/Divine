import 'package:divine/posts/screens/new_post_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/admobs/adHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../chats/screens/chat_screen.dart';
import '../models/post_model.dart';
import '../reels/screens/new_reels_screen.dart';
import '../stories/screens/confirm_story.dart';
import '../stories/stories_editor/stories_editor.dart';
import '../utilities/constants.dart';
import '../utilities/firebase.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/story_widget.dart';
import '../widgets/user_post.dart';

class FeedsPage extends StatefulWidget{
  const FeedsPage({
    super.key,
  });

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> with AutomaticKeepAliveClientMixin<FeedsPage>{
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  NativeAd? nativeAd;

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
      pagePosts += 3;
    });
    if(followingAccounts.isNotEmpty) {
      if(followingAccounts.length < 30) {
        if(posts.isNotEmpty) {
          querySnapshot = await postRef.where('ownerId', whereIn: followingAccounts)
              .orderBy('timestamp', descending: true)
              .startAfterDocument(posts.last)
              .limit(pagePosts).get();
        } else {
          querySnapshot = await postRef.where('ownerId', whereIn: followingAccounts)
              .orderBy('timestamp', descending: true)
              .limit(pagePosts).get();
        }
      } else {
        List<List<String>> batches = [];
        for(int i = 0; i < followingAccounts.length; i += 30) {
          batches.add(followingAccounts.skip(i).take(30).toList());
        }
        final snapshots = await getPosts(batches);
        // TODO: Fix it
        for(var snapshot in snapshots) {
          querySnapshot = snapshot as QuerySnapshot;
        }
      }
    } else {
      setState(() {
        loadingMorePosts = false;
        loadedPosts = true;
        loadMoreSuggested();
      });
      return;
    }
    setState(() {
      if (querySnapshot.docs.length < pagePosts || querySnapshot.docs.isEmpty) {
        loadedPosts = true;
        loadMoreSuggested();
      } else {
        posts.addAll(querySnapshot.docs);
      }
      loadingMorePosts = false;
    });
  }

  Future<List<dynamic>> getPosts(List<List<String>> batches) async {
    final queries = batches.map((batch) async {
      if(posts.isNotEmpty) {
        return await postRef.where('ownerId', whereIn: batch)
            .orderBy('timestamp', descending: true)
            .startAfterDocument(posts.last)
            .limit(pagePosts).get();
      } else {
        return await postRef.where('ownerId', whereIn: batch)
            .orderBy('timestamp', descending: true)
            .limit(pagePosts).get();
      }
    });
    final snapshots = await Future.wait(queries);
    final results = snapshots.map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList()).toList();
    return results;
  }

  Future<void> loadMoreSuggested() async {
    setState(() {
      loadingMoreSuggested = true;
      pageSuggested += 3;
    });
    if(suggested.isNotEmpty) {
      querySnapshot = await postRef.where('hashtags', arrayContainsAny: hashTags
          .take(hashTags.length > 10 ? 10 : hashTags.length))
          .orderBy('timestamp', descending: true)
          .startAfterDocument(suggested.last)
          .limit(pageSuggested).get();
    } else {
      querySnapshot = await postRef.where('hashtags', arrayContainsAny: hashTags
          .take(hashTags.length > 10 ? 10 : hashTags.length))
          .orderBy('timestamp', descending: true)
          .limit(pageSuggested).get();
    }
    setState(() {
      if (querySnapshot.docs.length < pageSuggested || querySnapshot.docs.isEmpty) {
        loadedSuggested = true;
      } else {
        suggested.addAll(querySnapshot.docs);
      }
      loadingMoreSuggested = false;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent
          && !loadingMorePosts && !loadingMoreSuggested && posts.isNotEmpty) {
        if (!loadedPosts) {
          loadMorePosts();
        } else if(!loadedSuggested) {
          loadMoreSuggested();
        }
        return;
      }
    });
    initUserData();
    NativeAd(
      adUnitId: adHelper.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            nativeAd = ad as NativeAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      factoryId: 'listTile',
    ).load();
  }

  initUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    followingAccounts = prefs.getStringList('followingAccounts') ?? [];
    hashTags = prefs.getStringList('hashTags') ?? [];
    setState(() {});
    await loadMorePosts();
  }

  @override
  void dispose() {
    nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);
    chooseUpload(BuildContext context, StoryViewModel viewModel) {
      return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20)
          ),
        ),
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: .75,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  border: const Border(
                    left: BorderSide(
                      color: Colors.blue,
                      width: 0.0,
                    ),
                    top: BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: Colors.blue,
                      width: 0.0,
                    ),
                    bottom: BorderSide(
                      color: Colors.blue,
                      width: 0.0,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                  )
              ),
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20)
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          bottom: 5.0,
                          left: 25.0,
                          right: 25.0,
                        ),
                        child:  Text(
                          'Create a new',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      )
                  ),
                  const Divider(
                    color: Colors.blue,
                    thickness: 1,
                  ),
                  const SizedBox(height: 10.0),
                  Visibility(
                      visible: !kIsWeb,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => StoriesEditor(
                            giphyKey: 'C4dMA7Q19nqEGdpfj82T8ssbOeZIylD4',
                            fontFamilyList: const ['Shizuru', 'Aladin', 'TitilliumWeb', 'Varela',
                              'Vollkorn', 'Rakkas', 'B612', 'YatraOne', 'Tangerine',
                              'OldStandardTT', 'DancingScript', 'SedgwickAve', 'IndieFlower', 'Sacramento'],
                            galleryThumbnailQuality: 300,
                            isCustomFontList: true,
                            onDone: (uri) {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => ConfirmStory(uri: uri),
                                ),
                              );
                            },
                          )));
                        },
                        child: Container(
                            height: 30.0,
                            padding: const EdgeInsets.only(
                              left: 25.0,
                              right: 25.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            color: Theme.of(context).colorScheme.background,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 3.0,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.time,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                    'Story',
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                      height: 0.9
                                    )
                                )
                              ],
                            )
                        ),
                      )
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Divider(
                      color: Colors.blue,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const NewPostScreen(
                                title: 'Create a Post',
                              ))
                      );
                    },
                    child: Container(
                        height: 30.0,
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          bottom: 2,
                        ),
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.background,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 3.0,
                              ),
                              child: Icon(
                                CupertinoIcons.plus_circle,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                                'Post',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                    height: 0.9
                                )
                            )
                          ],
                        )
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Divider(
                      color: Colors.blue,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Visibility(
                      visible: !kIsWeb,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const NewReelsScreen())
                          );
                        },
                        child: Container(
                            height: 30.0,
                            padding: const EdgeInsets.only(
                              left: 25.0,
                              right: 25.0,
                              bottom: 2,
                            ),
                            width: MediaQuery.of(context).size.width,
                            color: Theme.of(context).colorScheme.background,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 3.0,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.play_circle,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                    'Reel',
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                        height: 0.9
                                    )
                                )
                              ],
                            )
                        ),
                      )
                  ),
                  const SizedBox(height: 12.0),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Divider(
                      color: Colors.blue,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () async {
                      //
                      },
                    child: Container(
                        height: 30.0,
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          bottom: 2,
                        ),
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.background,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 3.0,
                              ),
                              child: Icon(
                                CupertinoIcons.equal_circle,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                                'Thread',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                    height: 0.9
                                )
                            )
                          ],
                        )
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            )
          );
        },
      );
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        systemOverlayStyle: Theme.of(context).colorScheme.background != Colors.black ? const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ) : const SystemUiOverlayStyle(
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
          colors: const [
            Colors.blue,
            Colors.pink,
            Colors.purple
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(
                CupertinoIcons.add_circled,
                size: 30.0,
              ),
              onPressed: () => {
                chooseUpload(context, viewModel),
              }
          ),
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
                    Expanded(
                        child: StoryWidget()
                    ),
                  ],
                ),
              ),
              // TODO: Fix Native Ad & implement it for iOS.
              /* if (nativeAd != null && Platform.isAndroid == true)
                SizedBox(
                  height: 100,
                  child: AdWidget(ad: nativeAd!),
                ),*/
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
                  child: postShimmer(),
              ),
              // TODO: Populate reels and threads too.
              followingAccounts.isNotEmpty && !loadedPosts ? Column(
                children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) {
                        PostModel model = PostModel.fromJson(posts[index].data() as Map<String, dynamic>);
                        return UserPost(post: model, index: index);
                      },
                    )
                  ],
              ) : const Padding(
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
              hashTags.isNotEmpty && loadedPosts ? Column(
                children: [
                  posts.isNotEmpty ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Colors.blue,
                        size: 30.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10
                        ),
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
                  ) : const SizedBox(),
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
                      PostModel model = PostModel.fromJson(suggested[index].data() as Map<String, dynamic>);
                      if(followingAccounts.contains(model.ownerId)) {
                        return const SizedBox();
                      } else {
                        return UserPost(post: model, index: index);
                      }
                    },
                  )
                ],
              ) : loadedSuggested ? const Padding(
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
              ) : const SizedBox(),
              if(loadingMoreSuggested)
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

  Widget postShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
      highlightColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[100]! : Colors.grey[800]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                ),
                width: 45.0,
                height: 45.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey[300],
                    ),
                    width: 150.0,
                    height: 15.0,
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey[300],
                    ),
                    width: 100.0,
                    height: 15.0,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
            width: 100.0,
            height: 15.0,
          ),
          const SizedBox(height: 12.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            width: double.infinity,
            height: 15.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            width: MediaQuery.of(context).size.width * 0.5,
            height: 15.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
            width: 150.0,
            height: 14.0,
          ),
          const SizedBox(height: 15.0),
        ],
      ),
    );
  }
}