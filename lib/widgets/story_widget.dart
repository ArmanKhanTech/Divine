import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../stories/screens/story_screen.dart';
import '../utilities/firebase.dart';

class StoryWidget extends StatefulWidget{
  final Function onDone;

  const StoryWidget({Key? key, required this.onDone}) : super(key: key);

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  @override
  void initState() {
    super.initState();
  }

  // TODO: Sort stories by time i.e viewed stories at last, tags in stories, location in stories, tagged stories within stories.
  @override
  Widget build(BuildContext context) {
    int storyCounter = 0;

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: viewerListStream(auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List storyList = snapshot.data!.docs;
            if (storyList.isNotEmpty) {

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                itemCount: storyList.length,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot storyListSnapshot = storyList[index];

                  return StreamBuilder<QuerySnapshot>(
                    stream: storyListStream(storyListSnapshot.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List stories = snapshot.data!.docs;
                        StoryModel story = StoryModel.fromJson(stories.first.data());
                        List users = storyListSnapshot.get('whoCanSee');
                        String uploadUserId = storyListSnapshot.get('userId');
                        if(users.contains(auth.currentUser!.uid) && uploadUserId != auth.currentUser!.uid){
                          users.remove(auth.currentUser!.uid);
                          storyCounter++;

                          return buildStatusAvatar(
                            storyListSnapshot.get('userId'),
                            storyListSnapshot.id,
                            story.storyId!,
                            index,
                          );
                        }
                        if(storyCounter == 0){
                          widget.onDone(true);
                        }

                        return const SizedBox();
                      } else {

                        return const SizedBox();
                      }
                    },
                  );
                },
              );
            } else {
              widget.onDone(true);

              return const SizedBox();
            }
          } else {

            return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(child: circularProgress(context, const Color(0xFFE91E63)))
            );
          }
        },
      ),
    );
  }

  buildStatusAvatar(
      String userId,
      String storiesId,
      String storyId,
      int index,
      ) {

    return StreamBuilder(
      stream: usersRef.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot = snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FutureBuilder<QuerySnapshot>(
              future: storyRef.doc(storiesId).collection('stories').get(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  List stories = snapshot.data!.docs;
                  StoryModel stats = StoryModel.fromJson(stories.toList()[stories.length - 1].data());
                  List<dynamic>? allViewers = stats.viewers;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => StoryScreen(
                                storyId: storyId,
                                storiesId: storiesId,
                                userId: userId,
                                initPage: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: !allViewers!.contains(auth.currentUser!.uid) ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: const GradientBoxBorder(
                              gradient: LinearGradient(colors: [Colors.blue, Colors.purple, Colors.pink]),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 2.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ) : BoxDecoration(
                            shape: BoxShape.circle,
                            border: const GradientBoxBorder(
                              gradient: LinearGradient(colors: [Colors.grey, Colors.grey, Colors.grey]),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 2.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: CachedNetworkImageProvider(
                                user.photoUrl!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        user.username!.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                      )
                    ],
                  );
                } else{

                  return const SizedBox();
                }
              },
            )
          );
        } else {

            return const SizedBox();
          }
      },
    );
  }

  Stream<QuerySnapshot> viewerListStream(String uid) {

    return storyRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> storyListStream(String documentId) {

    return storyRef.doc(documentId).collection('stories').snapshots();
  }
}