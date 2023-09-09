import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:shimmer/shimmer.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../stories/screens/confirm_story.dart';
import '../stories/screens/story_screen.dart';
import '../stories/stories_editor/stories_editor.dart';
import '../utilities/firebase.dart';

class StoryWidget extends StatefulWidget{
  const StoryWidget({Key? key}) : super(key: key);

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  int storyCounter = 0;

  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  // TODO: Sort stories by time i.e viewed stories at last, tags in stories, location in stories, tagged stories within stories.
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        isLoaded = true;
      });
    });

    return StreamBuilder<QuerySnapshot>(
      stream: viewerListStream(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List storyList = snapshot.data!.docs;
          if (storyList.isNotEmpty) {

            return ListView.builder(
              padding: const EdgeInsets.only(top: 4),
              itemCount: storyList.length + 1,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if(index == 0){

                  return buildOwnStoryAvatar();
                } else{
                  DocumentSnapshot storyListSnapshot = storyList[index - 1];

                  return StreamBuilder<QuerySnapshot>(
                    stream: storyListStream(storyListSnapshot.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List stories = snapshot.data!.docs;
                        StoryModel story = StoryModel.fromJson(stories.first.data());
                        List users = storyListSnapshot.get('whoCanSee');
                        String uploadUserId = storyListSnapshot.get('userId') ?? '';
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

                          return const SizedBox();
                        }

                        return const SizedBox();
                      } else {

                        return const SizedBox();
                      }
                    },
                  );
                }
              },
            );
          } else {

            return const SizedBox();
          }
        } else {

          return const SizedBox();
        }
      },
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
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
                            padding: const EdgeInsets.all(3.0),
                            child: user.photoUrl!.isNotEmpty ? CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              imageBuilder: (context, imageProvider) => Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(45)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder: (context, url, downloadProgress) {

                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.white,
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ) : CircleAvatar(
                              radius: 45.0,
                              backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                              child: Center(
                                child: Text(
                                  user.username![0].toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        user.username!.length > 8 ? '${user.username!.substring(0, 8).toLowerCase()}...' : user.username!.toLowerCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
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

  buildOwnStoryAvatar() {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            right: 5.0,
            bottom: 5.0,
            top: 2.0,
          ),
          child: StreamBuilder(
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
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        profileImage.photoUrl!.isNotEmpty ? CachedNetworkImage(
                          imageUrl: profileImage.photoUrl!,
                          imageBuilder: (context, imageProvider) => Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(48)),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          progressIndicatorBuilder: (context, url, downloadProgress) {

                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.white,
                              child: Container(
                                height: 96,
                                width: 96,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                      ) : CircleAvatar(
                            radius: 48.0,
                            backgroundColor: Colors.grey[200],
                            child: Center(
                              child: Text(
                                profileImage.username![0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                    )
                  );
                } else{

                  return const SizedBox();
                }
              }
          ),
        ),
        const SizedBox(
          height: 1.0,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15.0,
            ),
            isLoaded ? const Text(
              'Your story',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ) : const SizedBox(),
          ],
        )
      ],
    );
  }

  Stream<QuerySnapshot> viewerListStream(String uid) {

    return storyRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> storyListStream(String documentId) {

    return storyRef.doc(documentId).collection('stories').snapshots();
  }
}