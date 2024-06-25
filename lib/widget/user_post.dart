import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:divine/module/main/tab/profile_tab.dart';

import '../component/custom_card.dart';
import '../model/post_model.dart';
import '../model/user_model.dart';
import '../module/post/screen/view_post_screen.dart';
import '../service/post_service.dart';
import '../utility/firebase.dart';

class UserPost extends StatefulWidget {
  final PostModel? post;
  final int index;

  const UserPost({super.key, this.post, required this.index});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  final DateTime timestamp = DateTime.now();

  String currentUserId() {
    return auth.currentUser!.uid;
  }

  @override
  void initState() {
    super.initState();
  }

  final PostService services = PostService();

  @override
  Widget build(BuildContext context) {
    bool isMe = currentUserId() == widget.post!.ownerId;

    return Visibility(
      visible: !isMe,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.index != 0
                ? Container(
                    height: .5,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 50.0,
              child: buildUser(context),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.post!.mediaUrl!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => ViewPostScreen(
                            post: widget.post,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.post!.mediaUrl![index],
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          placeholder: (context, url) {
                            return Shimmer.fromColors(
                              baseColor:
                                  Theme.of(context).colorScheme.surface ==
                                          Colors.white
                                      ? Colors.grey[300]!
                                      : Colors.grey[700]!,
                              highlightColor:
                                  Theme.of(context).colorScheme.surface ==
                                          Colors.white
                                      ? Colors.grey[100]!
                                      : Colors.grey[800]!,
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
                          top: 20,
                          right: 20,
                          child: Visibility(
                            visible: widget.post!.mediaUrl!.length > 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.5),
                              ),
                              child: Text(
                                '${index + 1}/${widget.post!.mediaUrl!.length}',
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
                            visible: widget.post!.mentions!.isNotEmpty,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(5.0),
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .3,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20)),
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
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                top: 10.0,
                                                bottom: 5.0,
                                                left: 25.0,
                                              ),
                                              child: Text(
                                                'Mentions',
                                                style: TextStyle(
                                                  fontSize: 30.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.blue,
                                              thickness: 1.0,
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  widget.post!.mentions!.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    showProfile(context,
                                                        profileId: widget.post!
                                                            .mentions![index]);
                                                  },
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 25.0,
                                                  ),
                                                  leading: FutureBuilder(
                                                    future: usersRef
                                                        .doc(widget.post!
                                                            .mentions![index])
                                                        .get(),
                                                    builder: (context,
                                                        AsyncSnapshot<
                                                                DocumentSnapshot>
                                                            snapshot) {
                                                      if (snapshot.hasData) {
                                                        if (snapshot
                                                            .data!.exists) {
                                                          DocumentSnapshot
                                                              snap =
                                                              snapshot.data!;
                                                          UserModel user = UserModel
                                                              .fromJson(snap
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>);
                                                          return user.photoUrl!
                                                                  .isEmpty
                                                              ? CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                  child: Center(
                                                                    child: Text(
                                                                      user.username![
                                                                              0]
                                                                          .toUpperCase(),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: user
                                                                      .photoUrl!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    height: 40,
                                                                    width: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius: const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              30)),
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  progressIndicatorBuilder:
                                                                      (context,
                                                                          url,
                                                                          downloadProgress) {
                                                                    return Shimmer
                                                                        .fromColors(
                                                                      baseColor: Theme.of(context).colorScheme.surface ==
                                                                              Colors
                                                                                  .white
                                                                          ? Colors.grey[
                                                                              300]!
                                                                          : Colors
                                                                              .grey[700]!,
                                                                      highlightColor: Theme.of(context).colorScheme.surface ==
                                                                              Colors
                                                                                  .white
                                                                          ? Colors.grey[
                                                                              100]!
                                                                          : Colors
                                                                              .grey[800]!,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.grey,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  errorWidget:
                                                                      (context,
                                                                          url,
                                                                          error) {
                                                                    return CircleAvatar(
                                                                      radius:
                                                                          20,
                                                                      backgroundColor: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .secondary,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          user.username![0]
                                                                              .toUpperCase(),
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.blue,
                                                                            fontSize:
                                                                                15.0,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                        } else {
                                                          return CircleAvatar(
                                                            radius: 20,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary,
                                                            child: Center(
                                                              child: Text(
                                                                widget
                                                                    .post!
                                                                    .mentions![
                                                                        index]
                                                                        [0]
                                                                    .toUpperCase(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        return Shimmer
                                                            .fromColors(
                                                          baseColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .surface ==
                                                                  Colors.white
                                                              ? Colors
                                                                  .grey[300]!
                                                              : Colors
                                                                  .grey[700]!,
                                                          highlightColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .surface ==
                                                                  Colors.white
                                                              ? Colors
                                                                  .grey[100]!
                                                              : Colors
                                                                  .grey[800]!,
                                                          child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  title: Text(
                                                    widget
                                                        .post!.mentions![index],
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Ionicons.person,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                                padding: const EdgeInsets.only(bottom: 3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        padding: EdgeInsets.only(top: 1.0),
                        child: Icon(
                          Ionicons.chatbox_ellipses_outline,
                          size: 30.0,
                        ),
                      )),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      //
                    },
                    icon: const Icon(
                      Ionicons.bookmark_outline,
                      size: 28.0,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder(
                stream: likesRef
                    .where('postId', isEqualTo: widget.post!.postId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot snap = snapshot.data!;
                    List<DocumentSnapshot> docs = snap.docs;
                    return buildLikesCount(context, docs.length);
                  } else {
                    return Shimmer.fromColors(
                      baseColor:
                          Theme.of(context).colorScheme.surface == Colors.white
                              ? Colors.grey[300]!
                              : Colors.grey[700]!,
                      highlightColor:
                          Theme.of(context).colorScheme.surface == Colors.white
                              ? Colors.grey[100]!
                              : Colors.grey[800]!,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.grey[300],
                        ),
                        width: 100.0,
                        height: 15.0,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Visibility(
              visible: widget.post!.description != null &&
                  widget.post!.description.toString().isNotEmpty,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ExpandableText(
                    '${widget.post!.description!}\n\n${widget.post!.hashtags!.join(' ')}',
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
                      //
                    },
                    hashtagStyle: const TextStyle(
                      color: Colors.blue,
                    ),
                    onMentionTap: (username) {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => ProfileTab(
                            profileId: username,
                          ),
                        ),
                      );
                    },
                    mentionStyle: const TextStyle(
                      color: Colors.blue,
                    ),
                  )),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder(
                stream: commentRef
                    .doc(widget.post!.postId!)
                    .collection("comments")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot snap = snapshot.data!;
                    List<DocumentSnapshot> docs = snap.docs;
                    return buildCommentsCount(context, docs.length);
                  } else {
                    return Shimmer.fromColors(
                      baseColor:
                          Theme.of(context).colorScheme.surface == Colors.white
                              ? Colors.grey[300]!
                              : Colors.grey[700]!,
                      highlightColor:
                          Theme.of(context).colorScheme.surface == Colors.white
                              ? Colors.grey[100]!
                              : Colors.grey[800]!,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.grey[300],
                        ),
                        width: 150.0,
                        height: 15.0,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                timeago.format(widget.post!.timestamp!.toDate()),
                style: const TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
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
                'dateLiked': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              services.removeLikeFromNotification(
                  widget.post!.ownerId!,
                  widget.post!.postId!,
                  currentUserId(),
                  widget.post!.hashtags!);
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            padding: const EdgeInsets.all(0.0),
            isLiked: docs.isNotEmpty,
            circleColor: const CircleColor(
                start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: const BubblesColor(
                dotPrimaryColor: Color(0xffFFA500),
                dotSecondaryColor: Color(0xffd8392b),
                dotThirdColor: Color(0xffFF69B4),
                dotLastColor: Color(0xffff8c00)),
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

  void addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;
    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      services.addLikesToNotification(
        "like",
        user!.username!,
        currentUserId(),
        widget.post!.postId!,
        widget.post!.ownerId!,
        user!.photoUrl!,
        widget.post!.hashtags!,
      );
    }
  }

  Widget buildLikesCount(BuildContext context, int count) {
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

  Widget buildCommentsCount(BuildContext context, int count) {
    return Text(
      '$count comments',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 0.8,
        color: Colors.grey[600],
      ),
    );
  }

  Widget buildUser(BuildContext context) {
    return StreamBuilder(
      stream: usersRef.doc(widget.post!.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data!;
          UserModel user =
              UserModel.fromJson(snap.data() as Map<String, dynamic>);
          return Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  showProfile(context, profileId: user.id);
                },
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.photoUrl!.isEmpty
                            ? CircleAvatar(
                                radius: 22.5,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: Center(
                                  child: Text(
                                    user.username![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: user.photoUrl!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(45)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) {
                                  return Shimmer.fromColors(
                                    baseColor:
                                        Theme.of(context).colorScheme.surface ==
                                                Colors.white
                                            ? Colors.grey[300]!
                                            : Colors.grey[700]!,
                                    highlightColor:
                                        Theme.of(context).colorScheme.surface ==
                                                Colors.white
                                            ? Colors.grey[100]!
                                            : Colors.grey[800]!,
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
                                errorWidget: (context, url, error) {
                                  return CircleAvatar(
                                    radius: 22.5,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Center(
                                      child: Text(
                                        user.username![0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.post!.username!.toLowerCase(),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  height: 0.8),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            widget.post!.location != null &&
                                    widget.post!.location.toString().isNotEmpty
                                ? Text(
                                    widget.post!.location ?? ' ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 15.0,
                                      height: 0.8,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            //
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
              ));
        } else {
          return const SizedBox();
        }
      },
    );
  }

  void showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ProfileTab(profileId: profileId!),
      ),
    );
  }
}
