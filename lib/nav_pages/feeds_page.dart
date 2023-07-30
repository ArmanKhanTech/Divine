import 'package:divine/screens/new_post_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/admobs/adHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../screens/chat_screen.dart';
import '../stories/screens/confirm_story.dart';
import '../stories/stories_editor/stories_editor.dart';
import '../utilities/constants.dart';
import '../utilities/firebase.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/progress_indicators.dart';
import '../widgets/story_widget.dart';

// FeedsScreen.
class FeedsPage extends StatefulWidget{
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  NativeAd? nativeAd;

  int page = 5;
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

  // UI of FeedsScreen.
  @override
  Widget build(BuildContext context) {
    // ViewModel of Stories.
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);

    // Choose Dialog.
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
            heightFactor: .95,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                        child: Center(
                          child:Text(
                            'Choose',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                  ),
                  const Divider(
                    color: Colors.blue,
                    thickness: 1,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const SizedBox(width: 25.0),
                      Visibility(
                          visible: !kIsWeb,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => StoriesEditor(
                                giphyKey: 'C4dMA7Q19nqEGdpfj82T8ssbOeZIylD4',
                                fontFamilyList: const ['Shizuru', 'Aladin', 'TitilliumWeb', 'Varela',
                                  'Vollkorn', 'Rakkas', 'B612', 'ConcertOne', 'YatraOne', 'Tangerine',
                                  'OldStandardTT', 'DancingScript', 'SedgwickAve', 'IndieFlower', 'Sacramento', 'PressStart2P'],
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
                                height: 150.0,
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.time,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                        'Story',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue
                                        )
                                    )
                                  ],
                                )
                            ),
                          )
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const NewPostScreen())
                          );
                        },
                        child: Container(
                            height: 150.0,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.plus_circle,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                    'Post',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue
                                    )
                                )
                              ],
                            )
                        ),
                      ),
                      const SizedBox(width: 25.0),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    children: [
                      const SizedBox(width: 25.0),
                      Visibility(
                          visible: !kIsWeb,
                          child: GestureDetector(
                            /*onTap: () async {
                            // Navigator.pop(context);
                            await viewModel.pickImage(context: context);
                          },*/
                            child: Container(
                                height: 150.0,
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.play_circle,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                        'Reels',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue
                                        )
                                    )
                                  ],
                                )
                            ),
                          )
                      ),
                      const Spacer(),
                      GestureDetector(
                        /*onTap: () async {
                        // Navigator.pop(context);
                        await viewModel.pickImage(context: context);
                      },*/
                        child: Container(
                            height: 150.0,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.equal_circle,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                    'Threads',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue
                                    )
                                )
                              ],
                            )
                        ),
                      ),
                      const SizedBox(width: 25.0),
                    ],
                  )
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
          style: const TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.w400,
             fontFamily: 'Raleway',
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
              const StoryWidget(),
             // TODO: Fix Native Ad & implement it for iOS.
             /* if (nativeAd != null && Platform.isAndroid == true)
                SizedBox(
                  height: 100,
                  child: AdWidget(ad: nativeAd!),
                ),*/
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
                          //PostModel posts =
                          //PostModel.fromJson(docs[index].data());
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}