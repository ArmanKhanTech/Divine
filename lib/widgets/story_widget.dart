import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../screens/story_screen.dart';
import '../utilities/firebase.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  // StoryWidget display on top of FeedsPage.
  @override
  Widget build(BuildContext context) {
    uploadStory() {
      return Stack(
        children: <Widget>[
          Container(
              decoration: const BoxDecoration(color: Colors.white),
              alignment: Alignment.center,
              height: 240,
              child: Image.asset('assets/images/app_icon.png', fit: BoxFit.fill)
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.add),
          )
        ],
      );
    }

    return SizedBox(
      height: 110.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: userChatsStream(auth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List chatList = snapshot.data!.docs;
              if (chatList.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  itemCount: chatList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot statusListSnapshot = chatList[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: messageListStream(statusListSnapshot.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List statuses = snapshot.data!.docs;
                          StoryModel status = StoryModel.fromJson(
                            statuses.first.data(),
                          );
                          List users = statusListSnapshot.get('whoCanSee');
                          users.remove(auth.currentUser!.uid);
                          return _buildStatusAvatar(
                              statusListSnapshot.get('userId'),
                              statusListSnapshot.id,
                              status.statusId!,
                              index);
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'No story to show',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                );
              }
            } else {
              return circularProgress(context, const Color(0xFFB2C5D1));
            }
          },
        ),
      ),
    );
  }

  // StoryWidget display on top of ChatPage.
  _buildStatusAvatar(
      String userId,
      String chatId,
      String messageId,
      int index,
      ) {
    return StreamBuilder(
      stream: usersRef.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot = snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryScreen(
                          statusId: chatId,
                          storyId: messageId,
                          initPage: index,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    // TODO: Change border color if user view the story.
                    decoration: BoxDecoration(
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          user.photoUrl!,
                        ),
                      ),
                    ),
                  ),
                ),
               Text(
                  user.username!.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto',
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return statusRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return statusRef.doc(documentId).collection('statuses').snapshots();
  }
}