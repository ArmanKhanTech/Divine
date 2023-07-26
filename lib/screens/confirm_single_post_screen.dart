import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/custom_image.dart';
import '../stories_editor/presentation/widgets/animated_on_tap_button.dart';
import '../utilities/firebase.dart';
import '../view_models/screens/posts_view_model.dart';
import '../widgets/progress_indicators.dart';
import 'main_screen.dart';

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

    exitDialog({required PostsViewModel viewModel}) {

      return showDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierDismissible: true,
        builder: (c) =>
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetAnimationDuration: const Duration(milliseconds: 300),
            insetAnimationCurve: Curves.ease,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BlurryContainer(
                height: 220,
                color: Colors.black.withOpacity(0.15),
                blur: 5,
                padding: const EdgeInsets.all(20),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Do you really want to go back?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 0.1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 40,
                    ),

                    AnimatedOnTapButton(
                      onTap: () async {
                        viewModel.resetPost();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => const MainScreen()));
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent.shade200,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                      child: Divider(
                        color: Colors.white10,
                      ),
                    ),

                    AnimatedOnTapButton(
                      onTap: () {
                        Navigator.pop(c, true);
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      );
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        await exitDialog(viewModel: viewModel);
        return false;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        opacity: 0.5,
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.postScaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.chevron_back),
              onPressed: () {
                exitDialog(viewModel: viewModel);
              },
              iconSize: 30.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: GradientText(
              'Upload Post',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
              ), colors: const [
              Colors.blue,
              Colors.purple,
            ],
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadSinglePost(context);
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                    right: 20.0,
                    top: 5,
                  ),
                  child: Icon(
                    CupertinoIcons.check_mark_circled,
                    size: 30.0,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: viewModel.imgLink != null ? CustomImage(
                  imageUrl: viewModel.imgLink,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  fit: BoxFit.contain,
                ) : viewModel.mediaUrl == null ? Center(
                  child: Text(
                    'Upload a Photo',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontFamily: 'Raleway',
                      fontSize: 15.0,
                    ),
                  ),
                ) : Image.file(
                  viewModel.mediaUrl!,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  fit: BoxFit.contain,
                )
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Caption',
                style: TextStyle(
                  fontSize: 18.0,
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
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 18.0,
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
                      hintText: 'Eg. Los Angeles, California, USA',
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
                    size: 30.0,
                  ),
                  iconSize: 30.0,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => viewModel.getLocation(),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Mentions',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: const InputDecoration(
                  hintText: 'Eg. @john @jane @doe',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Hashtags',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              /*HashTagTextField(
                initialValue: viewModel.description,
                decoration: const InputDecoration(
                  hintText: 'Eg. #beautiful #place #nature',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}