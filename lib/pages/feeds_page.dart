import 'package:divine/posts/screens/new_post_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/admobs/adHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../chats/screens/chat_screen.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../reels/screens/new_reels_screen.dart';
import '../stories/screens/confirm_story.dart';
import '../stories/stories_editor/stories_editor.dart';
import '../utilities/constants.dart';
import '../utilities/firebase.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/progress_indicators.dart';
import '../widgets/story_widget.dart';
import '../widgets/user_post.dart';

class FeedsPage extends StatefulWidget{
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  NativeAd? nativeAd;

  int page = 3;

  double height = 125;

  bool loadingMore = true;

  ScrollController scrollController = ScrollController();

  List<String> followingAccounts = [];

  Map<String, dynamic>? hashTags;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 3;
          loadingMore = true;
        });
      }
    });

    initPage();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  initPage() async {
    await getHashTags();
    await getFollowingAccounts();
  }

  @override
  void dispose() {
    nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    /*onTap: () async {
                        // Navigator.pop(context);
                        await viewModel.pickImage(context: context);
                      },*/
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
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      extendBodyBehindAppBar: false,
      extendBody: false,
      body: RefreshIndicator(
        color: Colors.purple,
        onRefresh: () => postRef.orderBy('timestamp', descending: true).limit(page).get(),
        displacement: 50,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            // TODO: Populate reels and threads too.
            FutureBuilder(
              future: postRef.where('ownerId', whereIn: followingAccounts).orderBy('timestamp', descending: true).limit(page).get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var snap = snapshot.data;
                  List docs = snap!.docs;

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: docs.length,
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      PostModel posts = PostModel.fromJson(docs[index].data());

                      if(docs.length == index + 1) {
                        loadingMore = false;
                      }

                      if(followingAccounts.contains(posts.ownerId)) {

                        return UserPost(post: posts, index: index,);
                      } else {

                        return const SizedBox();
                      }
                    },
                  );
                }  else {

                  return Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.2),
                        child: circularProgress(context, Colors.blue)
                    ),
                  );
                }
              },
            ),
            if (loadingMore == true && page > 3)
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              ),
            if (loadingMore == false && page > 3)
              const Padding(
                padding: EdgeInsets.only(
                  top: 20.0,
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
              ),
            // get post id from hashTagsRef and get the post from postRef based on count in Map of hashTags
            /*FutureBuilder(
                future: hashTags != null ? hashTagsRef.doc(hashTags!.keys.first).get() : null,
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var snap = snapshot.data;
                    PostModel posts = PostModel.fromJson(snap!.data() as Map<String, dynamic>);

                    return UserPost(post: posts, index: 0,);
                  } else {

                    return const SizedBox();
                  }
                },
              )*/
          ],
        ),
      ),
    );
  }

  getHashTags() async {
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
    UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    hashTags = user.userHashtags;
  }

  getFollowingAccounts() async {
    QuerySnapshot snapshot = await followingRef
        .doc(auth.currentUser!.uid)
        .collection('userFollowing')
        .get();

    for (var doc in snapshot.docs) {
      followingAccounts.add(doc.id);
    }
  }
}