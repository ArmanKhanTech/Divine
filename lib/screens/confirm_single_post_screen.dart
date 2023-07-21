import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../components/custom_image.dart';
import '../models/user_model.dart';
import '../utilities/firebase.dart';
import '../view_models/screens/posts_view_model.dart';
import '../widgets/progress_indicators.dart';

class ConfirmSinglePostScreen extends  StatefulWidget{
  final String? mediaUrl;
  const ConfirmSinglePostScreen({Key? key, required this.mediaUrl}) : super(key: key);

  @override
  State<ConfirmSinglePostScreen> createState() => _ConfirmSinglePostScreenState();
}

class _ConfirmSinglePostScreenState extends State<ConfirmSinglePostScreen> {
  @override
  Widget build(BuildContext context) {

    currentUserId() {
      return auth.currentUser!.uid;
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.postScaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: const Text('Divine'),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadSinglePost(context);
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              const SizedBox(height: 15.0),
              StreamBuilder(
                stream: usersRef.doc(currentUserId()).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                      title: Text(
                        user.username!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.email!,
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: viewModel.imgLink != null ? CustomImage(
                  imageUrl: viewModel.imgLink,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  fit: BoxFit.cover,
                ) : viewModel.mediaUrl == null ? Center(
                  child: Text(
                    'Upload a Photo',
                    style: TextStyle(
                      color:
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ) : Image.file(
                  viewModel.mediaUrl!,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Post Caption'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: const InputDecoration(
                  hintText: 'Eg. This is very beautiful place!',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Location'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0.0),
                title: SizedBox(
                  width: 250.0,
                  child: TextFormField(
                    controller: viewModel.locationTEC,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0.0),
                      hintText: 'United States,Los Angeles!',
                      focusedBorder: UnderlineInputBorder(),
                    ),
                    maxLines: null,
                    onChanged: (val) => viewModel.setLocation(val),
                  ),
                ),
                trailing: IconButton(
                  tooltip: "Use your current location",
                  icon: const Icon(
                    CupertinoIcons.map_pin_ellipse,
                    size: 25.0,
                  ),
                  iconSize: 30.0,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => viewModel.getLocation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}