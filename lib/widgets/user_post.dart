import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/pages/profile_page.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../components/custom_card.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../posts/screens/view_post_screen.dart';
import '../services/post_service.dart';
import '../utilities/firebase.dart';

class UserPost extends StatelessWidget {
  final PostModel? post;

  final int index;

  UserPost({super.key, this.post, required this.index});

  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return auth.currentUser!.uid;
  }

  final PostService services = PostService();

  @override
  Widget build(BuildContext context) {
    bool isMe = currentUserId() == post!.ownerId;

    return Visibility(
      visible: !isMe,
      child: CustomCard(
        onTap: () {},
        child: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (BuildContext context, VoidCallback _) {

            return ViewPostScreen(post: post);
          },
          closedElevation: 0.0,
          onClosed: (v) {},
          closedColor: Theme.of(context).colorScheme.background,
          closedBuilder: (BuildContext context, VoidCallback openContainer) {

            return Column(
              children: [
                index != 0 ? Container(
                  height: .5,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).colorScheme.secondary,
                ) : const SizedBox(),
                const SizedBox(
                  height: 5,
                ),
                buildUser(context),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: post!.mediaUrl!.length,
                      itemBuilder: (context, index) {

                        return GestureDetector(
                          onTap: openContainer,
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: post!.mediaUrl![index],
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                placeholder: (context, url) {

                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.white,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) {

                                  return const Center(
                                    child: Icon(
                                      Ionicons.cloud_offline_outline,
                                      size: 50.0,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top : 20,
                                right: 20,
                                child: Visibility(
                                  visible: post!.mediaUrl!.length > 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 5.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.5),
                                    ),
                                    child: Text(
                                      '${index + 1}/${post!.mediaUrl!.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // show mentions
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Visibility(
                                  visible: post!.mentions!.isNotEmpty,
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(5.0),
                                    child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: const Icon(
                                        Ionicons.person,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      padding: const EdgeInsets.all(0.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Row(
                          children: [
                            buildLikeButton(),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                /*Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => Comments(post: post),
                                    ),
                                  );*/
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Ionicons.chatbox_ellipses_outline,
                                  size: 30.0,
                                ),
                              )
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {

                              },
                              icon: const Icon(
                                Ionicons.bookmark_outline,
                                size: 30.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: StreamBuilder(
                                stream: likesRef
                                    .where('postId', isEqualTo: post!.postId)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    QuerySnapshot snap = snapshot.data!;
                                    List<DocumentSnapshot> docs = snap.docs;

                                    return buildLikesCount(context, docs.length);
                                  } else {

                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.white,
                                      child: Container(
                                        height: 15.0,
                                        width: 65.0,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          StreamBuilder(
                            stream: commentRef
                                .doc(post!.postId!)
                                .collection("comments")
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot snap = snapshot.data!;
                                List<DocumentSnapshot> docs = snap.docs;

                                return buildCommentsCount(context, docs.length);
                              } else {

                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.white,
                                  child: Container(
                                    height: 15.0,
                                    width: 85.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Visibility(
                        visible: post!.description != null &&
                            post!.description.toString().isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0, top: 3.0),
                          child: ExpandableText(
                            '${post!.description!}\n\n${post!.hashtags!.join(' ')}',
                            expandText: 'show more',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.secondary,
                              height: 1.2,
                            ),
                            linkColor: Colors.grey,
                            animation: true,
                            collapseOnTextTap: true,
                            onHashtagTap: (name) {

                            },
                            hashtagStyle: const TextStyle(
                              color: Colors.blue,
                            ),
                            onMentionTap: (username) {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => ProfilePage(
                                    profileId: username,
                                  ),
                                ),
                              );
                            },
                            mentionStyle: const TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 0.0
                        ),
                        child: Text(
                          timeago.format(post!.timestamp!.toDate()),
                          style: const TextStyle(fontSize: 15.0, color: Colors.grey),
                        ),
                      ),
                     const SizedBox(height: 10.0),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildLikeButton() {

    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();

              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              services.removeLikeFromNotification(
                  post!.ownerId!, post!.postId!, currentUserId(), post!.hashtags!);

              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            padding: const EdgeInsets.all(0.0),
            isLiked: docs.isNotEmpty,
            circleColor: const CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: const BubblesColor(
                dotPrimaryColor: Color(0xffFFA500),
                dotSecondaryColor: Color(0xffd8392b),
                dotThirdColor: Color(0xffFF69B4),
                dotLastColor: Color(0xffff8c00)),
            likeBuilder: (bool isLiked) {

              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty
                    ? Theme.of(context).colorScheme.background == Colors.white
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

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      services.addLikesToNotification(
        "like",
        user!.username!,
        currentUserId(),
        post!.postId!,
        post!.ownerId!,
        user!.photoUrl!,
        post!.hashtags!,
      );
    }
  }

  buildLikesCount(BuildContext context, int count) {

    return Text(
      '$count likes',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
        height: 0.8,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {

    return Text(
      ' -  $count comments',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 0.8,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  buildUser(BuildContext context) {

    return StreamBuilder(
      stream: usersRef.doc(post!.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data!;
          UserModel user = UserModel.fromJson(snap.data() as Map<String, dynamic>);

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              child: GestureDetector(
                onTap: () => showProfile(context, profileId: user.id!),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      user.photoUrl!.isEmpty ? CircleAvatar(
                        radius: 22.5,
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
                      ) : CachedNetworkImage(
                        imageUrl: user.photoUrl!,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 45,
                          width: 45,
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
                              height: 45,
                              width: 45,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            post!.username!.toLowerCase(),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          post!.location != null &&
                              post!.location.toString().isNotEmpty ? Text(
                            post!.location ?? ' ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15.0,
                              height: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ) : const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {

                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {

          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.white,
            child: Container(
              height: 50.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          );
        }
      },
    );
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ProfilePage(profileId: profileId!),
      ),
    );
  }
}
