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

class StoryWidget extends StatefulWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  int storyCounter = 0;

  @override
  void initState() {
    super.initState();
  }

  /* TODO: Sort stories by time i.e viewed stories at last, tags in stories, location in stories, tagged stories within stories, post & threads within stories.*/
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: viewerListStream(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List storyList = snapshot.data!.docs;
          if (storyList.isNotEmpty) {
            return ListView.builder(
              itemCount: storyList.length + 1,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(
                      left: 18,
                    ),
                    child: SizedBox()
                  );
                }
                if(index == 0){
                  return buildOwnStoryAvatar();
                } else {
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
                        if(storyCounter == 0) {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FutureBuilder<QuerySnapshot>(
              future: storyRef.doc(storiesId).collection('stories').get(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  List stories = snapshot.data!.docs;
                  StoryModel stats = StoryModel.fromJson(stories.toList()[stories.length - 1].data());
                  List<dynamic>? allViewers = stats.viewers;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                height: 92,
                                width: 92,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(46)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              progressIndicatorBuilder: (context, url, downloadProgress) {
                                return Shimmer.fromColors(
                                  baseColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
                                  highlightColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[100]! : Colors.grey[800]!,
                                  child: Container(
                                    height: 92,
                                    width: 92,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return CircleAvatar(
                                  radius: 46.0,
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  child: Center(
                                    child: Text(
                                      user.username![0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ) : CircleAvatar(
                              radius: 46.0,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: Center(
                                child: Text(
                                  user.username![0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          user.username!.length > 8 ? '${user.username!.substring(0, 8).toLowerCase()}...' : user.username!.toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      )
                    ],
                  );
                } else {
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
    return Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 8.0,
        top: 2.0,
      ),
      child: StreamBuilder(
          stream: usersRef.doc(auth.currentUser!.uid).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel profileImage = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
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
                            height: 98,
                            width: 98,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(50)),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          progressIndicatorBuilder: (context, url, downloadProgress) {
                            return Shimmer.fromColors(
                              baseColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
                              highlightColor: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[100]! : Colors.grey[800]!,
                              child: Container(
                                height: 98,
                                width: 98,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return CircleAvatar(
                              radius: 49,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: Center(
                                child: Text(
                                  profileImage.username![0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ) : CircleAvatar(
                          radius: 49,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: Center(
                            child: Text(
                              profileImage.username![0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          right: 5.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Your story',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const SizedBox();
            }
          }
      ),
    );
  }

  Stream<QuerySnapshot> viewerListStream(String uid) {
    return storyRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> storyListStream(String documentId) {
    return storyRef.doc(documentId).collection('stories').snapshots();
  }
}