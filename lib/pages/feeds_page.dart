import 'package:cached_network_image/cached_network_image.dart';
import 'package:divine/models/user_model.dart';
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
import '../reels/screens/new_reels_screen.dart';
import '../stories/screens/confirm_story.dart';
import '../stories/stories_editor/stories_editor.dart';
import '../utilities/constants.dart';
import '../utilities/firebase.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/progress_indicators.dart';
import '../widgets/story_widget.dart';

class FeedsPage extends StatefulWidget{
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  NativeAd? nativeAd;

  int page = 5;

  double height = 125;

  bool loadingMore = false;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 5;
          loadingMore = true;
        });
      }
    });

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

    super.initState();
  }

  @override
  void dispose() {
    nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

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
                          top: 15.0,
                          bottom: 10.0,
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
                                        color: Colors.blue
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
                                    color: Colors.blue
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
                                        color: Colors.blue
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
                                    color: Colors.blue
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
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () =>
            postRef.orderBy('timestamp', descending: true).limit(page).get(),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Stack(
                            children: [
                              StreamBuilder(
                                  stream: usersRef.doc(auth.currentUser!.uid).snapshots(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      UserModel profileImage = UserModel.fromJson(
                                          snapshot.data!.data() as Map<String,
                                              dynamic>);

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, CupertinoPageRoute(builder: (context) => StoriesEditor(
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
                                        child: CircleAvatar(
                                          radius: 48.0,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage: profileImage.photoUrl!.isNotEmpty ? CachedNetworkImageProvider(
                                              profileImage.photoUrl!) : null,
                                          child: profileImage.photoUrl!.isEmpty ? Text(
                                            profileImage.username![0].toUpperCase(),
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ) : null,
                                        ),
                                      );
                                    } else{

                                      return const SizedBox();
                                    }
                                  }
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: Container(
                                  height: 25.0,
                                  width: 25.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 15.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Your Story',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Expanded(
                      child: StoryWidget()
                    )
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
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: postRef.orderBy('timestamp', descending: true).limit(page).get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var snap = snapshot.data;
                      List docs = snap!.docs;

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          PostModel posts = PostModel.fromJson(docs[index].data());
                          return const Padding(
                            padding: EdgeInsets.all(10.0),
                            //child: UserPost(post: posts),
                          );
                        },
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {

                      return Center(
                        child: circularProgress(context, const Color(0XFF03A9F4)),
                      );
                    } else {
                      return const Center(

                        child: Text(
                          'Nothing to Show.',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}