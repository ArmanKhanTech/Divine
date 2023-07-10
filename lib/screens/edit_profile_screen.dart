import 'package:divine/screens/profile_picture_screen.dart';
import 'package:divine/view_models/screens/posts_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/text_form_builder.dart';
import '../models/user_model.dart';
import '../regex/regex.dart';
import '../utilities/firebase.dart';
import '../view_models/screens/edit_profile_view_model.dart';
import '../widgets/progress_indicators.dart';

// Edit Profile Screen.
class EditProfileScreen extends StatefulWidget{
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>{
  UserModel? user;

  String currentUid() {
    return auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);
    PostsViewModel postsViewModel = Provider.of<PostsViewModel>(context);

    buildForm(EditProfileViewModel viewModel, BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: viewModel.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormBuilder(
                enabled: !viewModel.loading,
                initialValue: widget.user!.username,
                prefix: CupertinoIcons.person_fill,
                hintText: "Username",
                textInputAction: TextInputAction.next,
                validateFunction: Regex.validateName,
                onSaved: (String val) {
                  viewModel.setUsername(val);
                },
                whichPage: 'signup',
              ),
              const SizedBox(height: 10.0),
              TextFormBuilder(
                initialValue: widget.user!.country,
                enabled: !viewModel.loading,
                prefix: CupertinoIcons.globe,
                hintText: "Country",
                textInputAction: TextInputAction.next,
                validateFunction: Regex.validateName,
                onSaved: (String val) {
                  viewModel.setCountry(val);
                },
                whichPage: 'signup'
              ),
              const SizedBox(height: 10.0),
              TextFormBuilder(
                  initialValue: widget.user!.bio,
                  enabled: !viewModel.loading,
                  prefix: CupertinoIcons.info_circle_fill,
                  hintText: "Bio",
                  textInputAction: TextInputAction.next,
                  validateFunction: Regex.validateBio,
                  onSaved: (String val) {
                    viewModel.setBio(val);
                  },
                  whichPage: 'signup'
              ),
              const SizedBox(height: 10.0),
              TextFormBuilder(
                  initialValue: widget.user!.profession,
                  enabled: !viewModel.loading,
                  prefix: CupertinoIcons.briefcase_fill,
                  hintText: "Profession",
                  textInputAction: TextInputAction.next,
                  validateFunction: Regex.validateProfession,
                  onSaved: (String val) {
                    viewModel.setProfession(val);
                  },
                  whichPage: 'signup'
              ),
              const SizedBox(height: 10.0),
              TextFormBuilder(
                  initialValue: widget.user!.url,
                  enabled: !viewModel.loading,
                  prefix: CupertinoIcons.link_circle_fill,
                  hintText: "Link",
                  textInputAction: TextInputAction.next,
                  validateFunction: Regex.validateURL,
                  onSaved: (String val) {
                    viewModel.setLink(val);
                  },
                  whichPage: 'signup'
              ),
            ],
          ),
        ),
      );
    }

    // UI of Edit Profile.
    return FlutterWebFrame(
      builder: (context) {
        return LoadingOverlay(
          progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
          isLoading: viewModel.loading,
          child: Scaffold(
            key: viewModel.scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Column(
                children: [
                  const SizedBox(
                    height: 3.0,
                  ),
                  GradientText(
                    'Edit Profile',
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
                  viewModel.resetEditProfile();
                  Navigator.of(context).pop();
                },
                iconSize: 30.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
             actions: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save_as_outlined),
                      onPressed: () {
                        viewModel.editProfile(context);
                      },
                      iconSize: 25.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                  ],
                )
              ],
            ),
            body: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePictureScreen()))
                        .then((value) => setState(() {
                      viewModel.imgLink = value;
                      if(viewModel.imgLink != null) {
                        viewModel.showSnackBar('Profile picture uploaded successfully.', context);
                      }
                    })),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: widget.user!.photoUrl!.isEmpty ? const Padding(
                          padding: EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: AssetImage('assets/images/profile_png.png'),
                            backgroundColor: Colors.transparent,
                          ),
                        ) : viewModel.imgLink != null ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: NetworkImage(viewModel.imgLink!),
                          ),
                        ) : viewModel.image == null ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: NetworkImage(widget.user!.photoUrl!),
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: FileImage(viewModel.image!),
                          ),
                        ),
                      ),
                    )
                  ),
                ),
                buildForm(viewModel, context)
              ],
            ),
          ),
        );
      },
      maximumSize: const Size(475.0, 812.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,);
  }
}