import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/post_model.dart';
import '../models/user_model.dart';
import '../utilities/firebase.dart';
import '../widgets/progress_indicators.dart';

class ViewImageScreen extends StatefulWidget {
  final PostModel? post;

  const ViewImageScreen({super.key, this.post});

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

final DateTime timestamp = DateTime.now();

currentUserId() {
  return auth.currentUser!.uid;
}

UserModel? user;

class _ViewImageScreenState extends State<ViewImageScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: buildImage(context),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post!.username!,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        const Icon(Ionicons.alarm_outline, size: 13.0),
                        const SizedBox(width: 3.0),
                        Text(
                          timeago.format(widget.post!.timestamp!.toDate()),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                buildLikeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildImage(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: ListView.builder(
            itemBuilder: (context, index) {

              return CachedNetworkImage(
                imageUrl: widget.post!.mediaUrl![index],
                placeholder: (context, url) => circularProgress(context, Colors.grey),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
        )
      ),
    );
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .set({
        "type": "like",
        "username": user!.username!,
        "userId": currentUserId(),
        "userDp": user!.photoUrl,
        "postId": widget.post!.postId,
        "mediaUrl": widget.post!.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .get()
          .then((doc) => {
        if (doc.exists) {doc.reference.delete()}
      });
    }
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          // return IconButton(
          //   onPressed: () {
          //     if (docs.isEmpty) {
          //       likesRef.add({
          //         'userId': currentUserId(),
          //         'postId': widget.post!.postId,
          //         'dateCreated': Timestamp.now(),
          //       });
          //       addLikesToNotification();
          //     } else {
          //       likesRef.doc(docs[0].id).delete();
          //       removeLikeFromNotification();
          //     }
          //   },
          //   icon: docs.isEmpty
          //       ? Icon(
          //           CupertinoIcons.heart,
          //         )
          //       : Icon(
          //           CupertinoIcons.heart_fill,
          //           color: Colors.red,
          //         ),
          // );
          ///added animated like button
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': widget.post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              removeLikeFromNotification();
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor:
            const CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty ? Colors.grey : Colors.red,
                size: 25,
              );
            },
          );
        }

        return Container();
      },
    );
  }
}