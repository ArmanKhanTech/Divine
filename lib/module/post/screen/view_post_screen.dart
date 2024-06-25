import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../model/post_model.dart';
import '../../../model/user_model.dart';
import '../../../utility/firebase.dart';

class ViewPostScreen extends StatefulWidget {
  final PostModel? post;

  const ViewPostScreen({super.key, this.post});

  @override
  State<ViewPostScreen> createState() => _ViewPostScreenState();
}

final DateTime timestamp = DateTime.now();

String currentUserId() {
  return auth.currentUser!.uid;
}

UserModel? user;

class _ViewPostScreenState extends State<ViewPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.only(bottom: 2.0),
        ),
      ),
      body: Center(
        child: buildImage(context),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post!.username!.toLowerCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                          height: 1.3,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    Row(
                      children: [
                        const Icon(Ionicons.alarm_outline, size: 20.0),
                        const SizedBox(width: 5.0),
                        Text(
                          timeago.format(widget.post!.timestamp!.toDate()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0, height: 1.2, color: Colors.grey),
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

  // TODO: Background
  Widget buildImage(BuildContext context) {
    if (widget.post!.mediaUrl!.length > 1) {
      return ListView.builder(
        itemCount: widget.post!.mediaUrl!.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: widget.post!.mediaUrl![index],
            placeholder: (context, url) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface == Colors.white
                    ? Colors.grey[300]!
                    : Colors.grey[700]!,
                highlightColor:
                    Theme.of(context).colorScheme.surface == Colors.white
                        ? Colors.grey[100]!
                        : Colors.grey[800]!,
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                ),
              );
            },
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: widget.post!.mediaUrl![0],
        placeholder: (context, url) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface == Colors.white
                ? Colors.grey[300]!
                : Colors.grey[700]!,
            highlightColor:
                Theme.of(context).colorScheme.surface == Colors.white
                    ? Colors.grey[100]!
                    : Colors.grey[800]!,
            child: Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          );
        },
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
  }

  void addLikesToNotification() async {
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

  void removeLikeFromNotification() async {
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

  Widget buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

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
            circleColor: const CircleColor(
                start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty
                    ? Theme.of(context).colorScheme.surface == Colors.white
                        ? Colors.black
                        : Colors.white
                    : Colors.red,
                size: 30,
              );
            },
          );
        }

        return Container();
      },
    );
  }
}
