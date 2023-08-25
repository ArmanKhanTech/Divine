import 'package:divine/view_models/screens/posts_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../widgets/progress_indicators.dart';

class ProfilePictureScreen extends StatefulWidget{
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen>{
  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    showImageChoices(BuildContext context, PostsViewModel viewModel){
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext context) {

          return FractionallySizedBox(
            heightFactor: .6,
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
                          top: 15.0,
                          bottom: 15.0,
                          left: 25.0,
                        ),
                        child:  Text(
                          'Select from',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      )
                  ),
                  SizedBox(
                    height: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 25,
                      top: 15,
                      bottom: 8,
                    ),
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    leading: const Icon(CupertinoIcons.camera_fill, color: Colors.blue, size: 25),
                    title: Text('Camera', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                    onTap: () {
                      Navigator.pop(context);
                      // Open in camera.
                      viewModel.pickProfileImage(camera: true, context: context);
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 25,
                      top: 8,
                      bottom: 8,
                    ),
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    leading: const Icon(CupertinoIcons.photo_fill, color: Colors.blue, size: 25),
                    title: Text('Gallery', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                    onTap: () {
                      Navigator.pop(context);
                      // Open in gallery.
                      viewModel.pickProfileImage(camera: false, context: context);
                      // viewModel.pickProfilePicture();
                    },
                  ),
                ],
              ),
            )
          );
        },
      );
    }

    return FlutterWebFrame(
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            viewModel.resetPost();

            return true;
          },
          child: LoadingOverlay(
            progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
            opacity: 0.5,
            color: Theme.of(context).colorScheme.background,
            isLoading: viewModel.loading,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              key: viewModel.postScaffoldKey,
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Theme.of(context).colorScheme.background == Colors.white ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: Theme.of(context).colorScheme.background,
                  systemNavigationBarIconBrightness: Theme.of(context).colorScheme.background == Colors.white ? Brightness.dark : Brightness.light,
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                title: GradientText(
                  'Profile Picture',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                  ), colors: const [
                  Colors.blue,
                  Colors.purple,
                ],
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back),
                  onPressed: () {
                    // Reset post onBackPressed.
                    viewModel.resetPost();
                    Navigator.of(context).pop();
                  },
                  iconSize: 30.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  InkWell(
                    onTap: () => showImageChoices(context, viewModel),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.background,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: viewModel.media == null ? Center(
                          child: Text(
                            kIsWeb != true ?
                            'Tap to select your profile picture' : 'Click to select your profile picture',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontFamily: 'Raleway',
                              fontSize: 15.0,
                            ),
                          ),
                        ) : kIsWeb != true ? Image.file(
                          viewModel.media!,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.contain,
                        ) : Image.network(
                          viewModel.media!.path,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                      child: SizedBox(
                        height: 40.0,
                        width: 200.0,
                        child:  ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          child: const Text('Upload',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          onPressed: () => viewModel.uploadProfilePicture(context),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        );
      },
      maximumSize: const Size(540.0, 960.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}