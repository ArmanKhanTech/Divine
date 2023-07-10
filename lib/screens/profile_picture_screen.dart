import 'package:divine/view_models/screens/posts_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/custom_image.dart';
import '../widgets/progress_indicators.dart';

class ProfilePictureScreen extends StatefulWidget{
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen>{
  @override
  Widget build(BuildContext context) {
    // ViewModel of ProfilePictureScreen.
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    // Pick image from where camera or gallery.
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
            heightFactor: .5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                const Center(
                  child: Text(
                    'Select from',
                    textAlign: TextAlign.center,
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
                  leading: const Icon(CupertinoIcons.camera_fill, color: Colors.blue),
                  title: Text('Camera', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
                  onTap: () {
                    Navigator.pop(context);
                    // Open in camera.
                    viewModel.pickProfileImage(camera: true, context: context);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.photo_fill, color: Colors.blue),
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
          );
        },
      );
    }

    // UI of ProfilePictureScreen.
    return FlutterWebFrame(
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            // Reset post onBackPressed.
            viewModel.resetPost();
            return true;
          },
          child: LoadingOverlay(
            progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
            isLoading: viewModel.loading,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              key: viewModel.scaffoldKey,
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,),
                backgroundColor: Theme.of(context).colorScheme.background,
                title: Column(
                  children: [
                    const SizedBox(
                      height: 3.0,
                    ),
                    GradientText(
                      'Profile Picture',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ), colors: const [
                      Colors.blue,
                      Colors.purple,
                    ],
                    ),
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
                        shape:BoxShape.circle,
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
                          shape:BoxShape.circle,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: viewModel.mediaUrl == null ? Center(
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
                          viewModel.mediaUrl!,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.contain,
                        ) : Image.network(
                          viewModel.mediaUrl!.path,
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
                            elevation: MaterialStateProperty.all<double>(5.0),
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
      maximumSize: const Size(475.0, 812.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}