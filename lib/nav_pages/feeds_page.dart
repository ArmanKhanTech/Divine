import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../screens/chat_screen.dart';
import '../utilities/constants.dart';
import '../utilities/firebase.dart';
import '../view_models/user/status_view_model.dart';
import '../widgets/progress_indicators.dart';

// FeedsScreen.
class FeedsPage extends StatefulWidget{
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 5;
          loadingMore = true;
        });
      }
    });
    super.initState();
  }

  // Choose Dialog.
  chooseUpload(BuildContext context, StatusViewModel viewModel) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0),
              const Center(
                child:Text(
                  'Choose',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              const Divider(
                height: 1.0,
                color: Colors.blue,
              ),
              ListTile(
                leading: const Icon(
                    CupertinoIcons.photo_on_rectangle,
                    color: Colors.blue
                ),
                title: Text('Add to Stories', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                /*onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => CreatePost(),
                    ),
                  );
                },*/
              ),
              ListTile(
                leading: const Icon(
                    CupertinoIcons.plus_rectangle_on_rectangle,
                    color: Colors.blue
                ),
                title: Text('Make a new Post', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                /*onTap: () async {
                  // Navigator.pop(context);
                  await viewModel.pickImage(context: context);
                },*/
              ),
              ListTile(
                leading: const Icon(
                    CupertinoIcons.chat_bubble_text,
                    color: Colors.blue
                ),
                title: Text('Write Something', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                /*onTap: () async {
                  // Navigator.pop(context);
                  await viewModel.pickImage(context: context);
                },*/
              ),
              ListTile(
                leading: const Icon(
                    CupertinoIcons.camera,
                    color: Colors.blue
                ),
                title: Text('New Reels', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                /*onTap: () async {
                  // Navigator.pop(context);
                  await viewModel.pickImage(context: context);
                },*/
              ),
            ],
          ),
        );
      },
    );
  }

  // UI of FeedsScreen.
  @override
  Widget build(BuildContext context) {
    // ViewModel of Stories.
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,),
        title: GradientText(
          Constants.appName,
          style: const TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.w400,
             fontFamily: 'Raleway',
          ),
          colors: const [
            Colors.blue,
            Colors.pink,
            Colors.purple
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.add_circled,
              size: 30.0,
            ),
            onPressed: () => chooseUpload(context, viewModel),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.chat_bubble,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () =>
            postRef.orderBy('timestamp', descending: true).limit(page).get(),
        child: SingleChildScrollView(
          // controller: scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //StoryWidget(),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: postRef
                      .orderBy('timestamp', descending: true)
                      .limit(page)
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var snap = snapshot.data;
                      List docs = snap!.docs;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          //PostModel posts =
                          //PostModel.fromJson(docs[index].data());
                          return const Padding(
                            padding: EdgeInsets.all(10.0),
                            //child: UserPost(post: posts),
                          );
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: circularProgress(context),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Nothing to Show.',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}