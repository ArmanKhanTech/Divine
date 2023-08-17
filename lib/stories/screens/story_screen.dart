import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story/story_page_view/story_page_view.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../utilities/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../widgets/progress_indicators.dart';

class StoryScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final initPage, storiesId, storyId, userId;

  const StoryScreen({
    Key? key,
    required this.initPage,
    required this.storyId,
    required this.storiesId,
    required this.userId,
  }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {

    // TODO: DMs in story screen.
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: null,
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          Navigator.pop(context);
        },
        child: FutureBuilder<QuerySnapshot>(
          future: storyRef.doc(widget.storiesId).collection('stories').get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List story = snapshot.data!.docs;

              return StoryPageView(
                backgroundColor: Colors.black,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                indicatorHeight: 15.0,
                initialPage: widget.initPage,
                onPageLimitReached: () {
                  Navigator.pop(context);
                },
                indicatorVisitedColor: Colors.white,
                indicatorDuration: const Duration(seconds: 20),
                itemBuilder: (context, pageIndex, storyIndex) {
                  StoryModel stats = StoryModel.fromJson(story.toList()[storyIndex].data());
                  List<dynamic>? allViewers = stats.viewers;
                  if (!allViewers!.contains(auth.currentUser!.uid)) {
                    allViewers.add(auth.currentUser!.uid);
                    storyRef
                        .doc(widget.storiesId)
                        .collection('stories')
                        .doc(stats.storyId)
                        .update({'viewers': allViewers});
                  }

                  return Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                       SizedBox(
                         child: ClipRRect(
                           borderRadius: BorderRadius.circular(20),
                           child: Center(
                               child: getImage(stats.url!)
                           ),
                         )
                       ),
                        Positioned(
                          top: 30.0,
                          left: 15.0,
                          child: FutureBuilder(
                            future: usersRef.doc(widget.userId).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                DocumentSnapshot documentSnapshot = snapshot
                                    .data as DocumentSnapshot<Object?>;
                                UserModel user = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

                                return Padding(
                                  padding:
                                  const EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(1.0),
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                          CachedNetworkImageProvider(
                                            user.photoUrl!,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              user.username!.toLowerCase(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                background: Paint()
                                                  ..color = Colors.transparent,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              timeago.format(
                                                  stats.time!.toDate()),
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                background: Paint()
                                                  ..color = Colors.transparent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {

                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: widget.userId == auth.currentUser!.uid ? 10.0 : 30.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.userId == auth.currentUser!.uid)
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 20.0,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  label: Text(
                                    stats.viewers!.length.toString(),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                storyLength: (int pageIndex) {

                  return story.length;
                },
                pageLength: 1,
              );
            }

            return Center(
                child: circularProgress(context, const Color(0xffffffff)),
            );
          }
        ),
      ),
    );
  }

  getImage(String url) {

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {

            return child;
          }

          return Center(
            child: circularProgress(context, const Color(0xffffffff)),
          );
        },
      ),
    );
  }
}