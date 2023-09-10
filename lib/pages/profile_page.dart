import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/profile/screens/user_info_screen.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/stream_grid_wrapper.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../profile/screens/edit_profile_screen.dart';
import '../profile/screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../utilities/firebase.dart';
import '../widgets/post_tile.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;

  const ProfilePage({super.key, required this.profileId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  UserModel currentUser = UserModel();

  int postCount = -1;
  int followersCount = 0;
  int followingCount = 0;

  bool isFollowing = false, requested = false, isLoaded = false;

  UserModel? users;

  final DateTime timestamp = DateTime.now();

  ScrollController controller = ScrollController();

  GlobalKey<ScaffoldState> profileScaffoldKey = GlobalKey<ScaffoldState>();

  String? name = '';

  int tabIndex = 0;

  currentUserId() {
    return auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    checkIfRequested();
  }

  @override
  void dispose() {
    controller.dispose();
    name = '';
    postCount = 0;
    followersCount = 0;
    followingCount = 0;
    isFollowing = false;
    requested = false;
    users = null;
    currentUser = UserModel();
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

  checkIfRequested() async {
    QuerySnapshot doc = await notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .where('type', isEqualTo: 'follow')
        .where('userId', isEqualTo: currentUserId())
        .get();

    setState(() {
      requested = doc.docs.isNotEmpty;
    });
  }

  openMenu(BuildContext context) {

    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20)
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (BuildContext context) {

        return FractionallySizedBox(
          heightFactor: .7,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
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
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                        left: 25.0,
                      ),
                      child:  Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    )
                ),
                const Divider(
                  color: Colors.blue,
                  thickness: 1.0,
                ),
                Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 25,
                          bottom: 8,
                        ),
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        leading: Icon(
                          CupertinoIcons.info,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 25,
                        ),
                        title: Text(
                            'About this Account',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Ubuntu-Regular',
                            )
                        ),
                        minLeadingWidth: 10,
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (_) => UserInfoScreen(
                                country: currentUser.country,
                                email: currentUser.email,
                                timeStamp: currentUser.signedUpAt,
                              ),
                            ),
                          );
                        },
                      ),
                      Visibility(
                          visible: widget.profileId == auth.currentUser!.uid,
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(
                              left: 25,
                              bottom: 8,
                            ),
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            leading: Icon(
                              CupertinoIcons.settings,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            title: Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Ubuntu-Regular',
                                )
                            ),
                            minLeadingWidth: 10,
                            onTap: () async {
                              Navigator.of(context).pushReplacement(
                                  CupertinoPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ));
                            },
                          )
                      ),
                      Visibility(
                        visible: widget.profileId == auth.currentUser!.uid,
                        child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(
                              left: 25,
                              bottom: 8,
                            ),
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            onTap: () async {
                              await auth.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  CupertinoPageRoute(builder: (_) => const SplashScreen()), (route) => false);
                            },
                            title: Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Ubuntu-Regular',
                                )
                            ),
                            minLeadingWidth: 10,
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            )
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        name = currentUser.username;
        isLoaded = true;
      });
    });

    return Scaffold(
      key: profileScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        title: widget.profileId == auth.currentUser!.uid ? GradientText(
          'Your Profile',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ), colors: const [
              Colors.blue,
              Colors.purple,
            ],
        ) : Text(
          name.toString(),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: widget.profileId == auth.currentUser!.uid ? null : IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.only(bottom: 2.0),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  openMenu(context);
                },
                iconSize: 30.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 10.0),
            ],
          )
        ],
      ),
      body: StreamBuilder(
        stream: usersRef.doc(widget.profileId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            currentUser = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 18.0,
                    ),
                    // TODO: Implement user story widget & view profile picture.
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: currentUser.photoUrl!.isEmpty ? CircleAvatar(
                        radius: 48.0,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Center(
                          child: Text(
                            currentUser.username![0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ) : CachedNetworkImage(
                        imageUrl: '${currentUser.photoUrl}',
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
                        placeholder: (context, url) {

                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Theme.of(context).colorScheme.secondary,
                            child: const SizedBox(),
                          );
                        },
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder(
                      stream: postRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          QuerySnapshot<Object?>? snap = snapshot.data;
                          List<DocumentSnapshot> docs = snap!.docs;
                          postCount = docs.length;

                          return buildCount("Posts", docs.length);
                        } else {

                          return buildCount("Posts", 0);
                        }
                      },
                    ),
                    const Spacer(),
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
                    const Spacer(),
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
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: currentUser.name!.isNotEmpty ? Text(
                    currentUser.name!,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    maxLines: 1,
                  ) : Text(
                    currentUser.username!,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 2),
                  child: currentUser.profession!.isEmpty ? Text(
                    currentUser.country!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                    maxLines: 1,
                  ) : Text(
                    currentUser.profession![0].toUpperCase() + currentUser.profession!.substring(1),
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.pink,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 2),
                  child: currentUser.bio!.isEmpty ? const SizedBox(
                    height: 0.0,
                    width: 0.0,
                  ) : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ExpandableText(
                      currentUser.bio!,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      expandText: 'show more',
                      maxLines: 5,
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
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 2),
                  child: currentUser.link!.isEmpty ? const SizedBox(
                    height: 0.0,
                    width: 0.0,
                  ) : Row(
                    children: [
                      const Icon(
                        CupertinoIcons.link,
                        color: Colors.deepPurple,
                        size: 15,
                      ),
                      const SizedBox(width: 4.0),
                      SizedBox(
                          width: 200,
                          child: GestureDetector(
                            child: Text(
                              currentUser.link!,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.deepPurple,
                                height: 1.2,
                              ),
                            ),
                          )
                      ),
                    ],
                  )
                ),
                // TODO: Show mutual followers
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Text(
                                'Followed by ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Ubuntu-Regular',
                                  color: Theme.of(context).colorScheme.secondary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Text(
                                'username, username',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                buildProfileButton(currentUser),
                const SizedBox(height: 5.0),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                      length: 4,
                      initialIndex: tabIndex,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            child: TabBar(
                              dividerColor: Colors.transparent,
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.blue,
                              onTap: (index) {
                                setState(() {
                                  tabIndex = index;
                                });
                              },
                              tabs: const [
                                Tab(
                                  icon: Icon(CupertinoIcons.square_grid_2x2_fill, size: 25),
                                ),
                                Tab(
                                  icon: Icon(CupertinoIcons.play_circle_fill, size: 26),
                                ),
                                Tab(
                                  icon: Icon(CupertinoIcons.equal_circle_fill, size: 25),
                                ),
                                Tab(
                                  icon: Icon(CupertinoIcons.rectangle_grid_1x2_fill, size: 22),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (BuildContext context) {
                                switch (tabIndex) {
                                  case 0:
                                    return buildPostView(currentUser);
                                  case 1:
                                    return const Center(
                                      child: Text(
                                        'No Videos',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  case 2:
                                    return const Center(
                                      child: Text(
                                        'No Tagged Posts',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  case 3:
                                    return const Center(
                                      child: Text(
                                        'No Saved Posts',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  default:
                                    return const SizedBox();
                                }
                              },
                            )
                          )
                        ],
                      )
                  ),
                )
              ],
            );
          }

          if(widget.profileId == auth.currentUser!.uid) {

            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: circularProgress(context, Colors.blue),
              ),
            );
          } else {

            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: circularProgress(context, Colors.blue),
              ),
            );
          }
        },
      ),
    );
  }

  buildCount(String label, int count) {
    if(count > 1000) {
      count = (count / 1000).round();
      label = '${label}K';
    } else if(count > 1000000) {
      count = (count / 1000000).round();
      label = '${label}M';
    }

    return Column(
      children: <Widget>[
        const SizedBox(
          height: 5.0,
        ),
        Text(
          count.toString(),
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.secondary,
            height: 1.0,
          ),
        )
      ],
    );
  }

  // TODO: Implement private profile button
  buildProfileButton(user) {
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
      // TODO: Implement DM button
    } else if (isFollowing) {

      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
    } else if (!isFollowing && user.type == "public") {

      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    } else if(!isFollowing && user.type == "private" && !requested) {

      return buildButton(
        text: "Request",
        function: handleFollowRequest,
      );
    } else if(!isFollowing && user.type == "private" && requested) {

      return buildButton(
        text: "Requested",
        function: () {},
      );
    }
  }

  buildButton({String? text, Function()? function}) {

    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            height: 40.0,
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
                    fontSize: 18
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

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});

    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

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

  handleFollowRequest() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();

    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);

    setState(() {
      requested = true;
    });

    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "followRequest",
      "ownerId": widget.profileId,
      "username": users?.username,
      "userId": users?.id,
      "userDp": users?.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildPostView(UserModel currentUser) {
    if(isLoaded) {
      if(widget.profileId != auth.currentUser?.uid){
        if(currentUser.type == 'private' && isFollowing == false) {

          return const Center(
            child: Text(
              'This account is private.',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {

          return buildGridPost();
        }
      } else {

        return buildGridPost();
      }
    } else {

      return const SizedBox();
    }
  }

  buildGridPost() {
    if(postCount > 0 && isLoaded) {

      return StreamGridWrapper(
        shrinkWrap: true,
        stream: postRef
            .where('ownerId', isEqualTo: widget.profileId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0.0),
        loadingPadding: widget.profileId == auth.currentUser!.uid ? const EdgeInsets.only(bottom: 20) : const EdgeInsets.only(top: 40.0),
        itemBuilder: (_, DocumentSnapshot snapshot) {
          PostModel posts = PostModel.fromJson(snapshot.data() as Map<String, dynamic>);

          return PostTile(
            post: posts,
          );
        },
      );
    } else {

      return const SizedBox();
    }
  }
}