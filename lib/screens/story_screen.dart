import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_page_view/story_page_view.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../utilities/firebase.dart';
import '../utilities/system_ui.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/progress_indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryScreen extends StatefulWidget {
  final initPage;
  final statusId;
  final storyId;
  final userId;

  const StoryScreen({
    Key? key,
    required this.initPage,
    required this.storyId,
    required this.statusId,
    required this.userId,
  }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: DMs in story screen.
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);

    SystemUI.darkSystemUI();

    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          Navigator.pop(context);
        },
        child: FutureBuilder<QuerySnapshot>(
          future: statusRef.doc(widget.statusId).collection('statuses').get(),
          builder: (context, snapshot) {
            List status = snapshot.data!.docs;
            return snapshot.connectionState == ConnectionState.waiting
                ? circularProgress(context, const Color(0xFFB2C5D1))
                : StoryPageView(
              indicatorPadding:
              const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
              indicatorHeight: 15.0,
              initialPage: 0,
              onPageLimitReached: () {
                Navigator.pop(context);
              },
              indicatorVisitedColor:
              Theme.of(context).colorScheme.secondary,
              indicatorDuration: const Duration(seconds: 30),
              itemBuilder: (context, pageIndex, storyIndex) {
                StoryModel stats = StoryModel.fromJson(
                  status.toList()[storyIndex].data(),
                );
                List<dynamic>? allViewers = stats.viewers;
                if (allViewers!.contains(auth.currentUser!.uid)) {
                  //
                } else {
                  allViewers.add(auth.currentUser!.uid);
                  statusRef
                      .doc(widget.statusId)
                      .collection('statuses')
                      .doc(stats.statusId)
                      .update({'viewers': allViewers});
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: getImage(stats.url!),
                      ),
                      Positioned(
                        top: 65.0,
                        left: 10.0,
                        child: FutureBuilder(
                          future: usersRef.doc(widget.userId).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              DocumentSnapshot documentSnapshot = snapshot
                                  .data as DocumentSnapshot<Object?>;
                              UserModel user = UserModel.fromJson(
                                  documentSnapshot.data()
                                  as Map<String, dynamic>);
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
                                    Column(
                                      children: [
                                        Text(
                                          user.username!.toLowerCase(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(stats.time!.toDate()),
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )
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
                        bottom:
                        widget.userId == auth.currentUser!.uid
                            ? 10.0
                            : 30.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.userId ==
                                auth.currentUser!.uid)
                              TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 20.0,
                                  color:
                                  Theme.of(context).iconTheme.color,
                                ),
                                label: Text(
                                  stats.viewers!.length.toString(),
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color:
                                    Theme.of(context).iconTheme.color,
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
                return status.length;
              },
              pageLength: 1,
            );
          },
        ),
      ),
    );
  }

  getImage(String url) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Image.network(url),
    );
  }
}