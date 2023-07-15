import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/screens/profile_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/stream_grid_wrapper.dart';
import '../models/user_model.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/list_posts.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../utilities/firebase.dart';

class ProfilePage extends StatefulWidget {
  final profileId;
  const ProfilePage({super.key, this.profileId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  late UserModel currentUser;

  bool isLoading = false;

  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;

  bool isFollowing = false;

  UserModel? users;

  final DateTime timestamp = DateTime.now();

  ScrollController controller = ScrollController();

  GlobalKey<ScaffoldState> profileScaffoldKey = GlobalKey<ScaffoldState>();

  currentUserId() {
    return auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: profileScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: GradientText(
          'Profile',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w300,
          ), colors: const [
              Colors.blue,
              Colors.purple,
            ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: widget.profileId == auth.currentUser!.uid,
            child: Row(
              children: [
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.settings,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 25,
                  )
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () async {
                  await auth.signOut();
                  Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                          builder: (_) => const SplashScreen()
                      )
                    );
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 25,
                  )
                ),
                const SizedBox(width: 20.0),
              ],
            )
          )
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 350.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: usersRef.doc(widget.profileId).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    currentUser = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>,);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: currentUser.photoUrl!.isEmpty ? CircleAvatar(
                                radius: 50.0,
                                backgroundColor: Colors.grey,
                                child: Center(
                                  child: Text(
                                    currentUser.username![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ) : CircleAvatar(
                                radius: 50.0,
                                backgroundImage:
                                CachedNetworkImageProvider(
                                  '${currentUser.photoUrl}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 25.0),
                                Row(
                                  children: [
                                    const Visibility(
                                      visible: false,
                                      child: SizedBox(width: 10.0),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 150.0,
                                          child: currentUser.name!.isNotEmpty ? Text(
                                            currentUser.name!,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: null,
                                          ) : Text(
                                            currentUser.username!,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: null,
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        SizedBox(
                                          child: currentUser.profession!.isEmpty ? SizedBox(
                                            child: Text(
                                            currentUser.country!,
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.pink,
                                                fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ) : SizedBox(
                                                  child: Text(
                                                    currentUser.profession![0].toUpperCase() + currentUser.profession!.substring(1),
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.deepPurpleAccent,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: SizedBox(
                            width: 200,
                            child: currentUser.name!.isNotEmpty ? Text(
                              currentUser.username!.toLowerCase(),
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: null,
                            ) : Text(
                              currentUser.country!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.pink
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: currentUser.bio!.isEmpty ? Container() : SizedBox(
                            width: 200,
                            child: Text(
                              currentUser.bio!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),
                        // TODO: Implement open browser
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: currentUser.link!.isEmpty ? Container() : SizedBox(
                            width: 200,
                            child: GestureDetector(
                              child: Text(
                                currentUser.link!,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple,
                                ),
                                maxLines: null,
                              ),
                            )
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 60.0,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                StreamBuilder(
                                  stream: postRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap = snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;

                                      return buildCount("Posts", docs.length);
                                    } else {
                                      return buildCount("Posts", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 60.0,
                                    width: 1,
                                    color: Colors.blue,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: followersRef.doc(widget.profileId).collection('userFollowers').snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap = snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;
                                      return buildCount("Followers", docs.length);
                                    } else {
                                      return buildCount("Followers", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 60.0,
                                    width: 0.5,
                                    color: Colors.blue,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: followingRef.doc(widget.profileId).collection('userFollowing').snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap = snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;

                                      return buildCount("Following", docs.length);
                                    } else {
                                      return buildCount("Following", 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildProfileButton(currentUser),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 8
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'All Posts',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              DocumentSnapshot doc = await usersRef.doc(widget.profileId).get();
                              var currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>,);
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => ProfileInfoScreen(
                                    country: currentUser.country,
                                    email: currentUser.email,
                                    timeStamp: currentUser.signedUpAt,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              CupertinoIcons.info,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 25,
                            )
                          ),
                          IconButton(
                            onPressed: () async {
                              DocumentSnapshot doc = await usersRef.doc(widget.profileId).get();
                              var currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>,);
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ListPosts(
                                    userId: widget.profileId,
                                    username: currentUser.username,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(CupertinoIcons.square_grid_2x2, size: 25,),
                          )
                        ],
                      ),
                    ),
                    buildPostView()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'Ubuntu-Regular',
          ),
        )
      ],
    );
  }

  buildProfileButton(user) {
    // if isMe then display "edit profile"
    bool isMe = widget.profileId == auth.currentUser!.uid;
    if (isMe) {
      return buildButton(
          text: "Edit Profile",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfileScreen(
                  user: user,
                ),
              ),
            );
          });
      // if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      // if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

  buildButton({String? text, Function()? function}) {
    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 35.0,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: text == "Edit Profile" ? Colors.grey : text == "Follow" ? Colors.blue : Colors.red,
            ),
            child: Center(
              child: Text(
                text!,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
            ),
          ),
        )
      ),
    );
  }

  handleUnfollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": users?.username,
      "userId": users?.id,
      "userDp": users?.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildPostView() {
    return buildGridPost();
  }

  buildGridPost() {
    return StreamGridWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: postRef
          .where('ownerId', isEqualTo: widget.profileId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        return const SizedBox();
        /*PostModel posts = PostModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return PostTile(
          post: posts,
        );*/
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: favUsersRef
          .where('postId', isEqualTo: widget.profileId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          return GestureDetector(
            onTap: () {
              if (docs.isEmpty) {
                favUsersRef.add({
                  'userId': currentUserId(),
                  'postId': widget.profileId,
                  'dateCreated': Timestamp.now(),
                });
              } else {
                favUsersRef.doc(docs[0].id).delete();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3.0,
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Icon(
                  docs.isEmpty
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}