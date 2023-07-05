import 'package:divine/view_models/auth/posts_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../auth/login_page.dart';
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
                const SizedBox(height: 10.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Select from',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Divider(
                  height: 1.0,
                  color: Colors.blue,
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.camera_fill, color: Colors.blue),
                  title: Text('Camera', style: TextStyle(fontSize: 15.0, color: Theme.of(context).colorScheme.secondary)),
                  onTap: () {
                    Navigator.pop(context);
                    // Open in camera.
                    viewModel.pickProfileImage(camera: true, context: context);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.photo_fill, color: Colors.blue),
                  title: Text('Gallery', style: TextStyle(fontSize: 15.0, color: Theme.of(context).colorScheme.secondary)),
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
    return WillPopScope(
      onWillPop: () async {
        // Reset post onBackPressed.
        viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
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
                  'Upload a profile picture',
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
                Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => const LoginPage(),
                    ));
              },
              iconSize: 30.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.2,
              ),
              InkWell(
                onTap: () => showImageChoices(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                  ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                          imageUrl: viewModel.imgLink,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.cover,
                        ) : viewModel.mediaUrl == null
                      ? const Center(
                          child: Text(
                            'Tap to add your profile picture',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Raleway',
                            ),
                          ),
                        ) : Image.file(
                              viewModel.mediaUrl!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            ),
                ),
                ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondary),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('done'.toUpperCase()),
                    ),
                  ),
                  onPressed: () => viewModel.uploadProfilePicture(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}