import 'package:cached_network_image/cached_network_image.dart';
import 'package:divine/profile/screens/profile_picture_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../components/text_form_builder.dart';
import '../../models/user_model.dart';
import '../../utilities/regex.dart';
import '../../utilities/firebase.dart';
import '../../view_models/screens/edit_profile_view_model.dart';
import '../../widgets/progress_indicators.dart';

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

    buildForm(EditProfileViewModel viewModel, BuildContext context) {

      return Form(
        key: viewModel.editProfileFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormBuilder(
              capitalization: false,
              enabled: !viewModel.loading,
              initialValue: widget.user!.username,
              prefix: CupertinoIcons.person_solid,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateUsername,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
              whichPage: 'signup',
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
              capitalization: true,
              enabled: !viewModel.loading,
              initialValue: widget.user!.name,
              prefix: CupertinoIcons.person,
              hintText: "Name",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateName,
              onSaved: (String val) {
                viewModel.setName(val);
              },
              whichPage: 'signup',
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
                capitalization: true,
                initialValue: widget.user!.country,
                enabled: !viewModel.loading,
                prefix: CupertinoIcons.globe,
                hintText: "Country",
                textInputAction: TextInputAction.next,
                validateFunction: Regex.validateCountry,
                onSaved: (String val) {
                  viewModel.setCountry(val);
                },
                whichPage: 'signup'
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
                capitalization: true,
                initialValue: widget.user!.bio,
                enabled: !viewModel.loading,
                prefix: CupertinoIcons.info_circle,
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
                capitalization: true,
                initialValue: widget.user!.profession,
                enabled: !viewModel.loading,
                prefix: CupertinoIcons.briefcase,
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
                capitalization: true,
                initialValue: widget.user!.gender,
                enabled: !viewModel.loading,
                prefix: Icons.male,
                hintText: "Gender",
                textInputAction: TextInputAction.next,
                validateFunction: Regex.validateGender,
                onSaved: (String val) {
                  viewModel.setGender(val);
                },
                whichPage: 'signup'
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
                capitalization: false,
                iconSize: 20,
                initialValue: widget.user!.link,
                enabled: !viewModel.loading,
                prefix: CupertinoIcons.link,
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
      );
    }

    return FlutterWebFrame(
      builder: (context) {
        return LoadingOverlay(
          progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
          isLoading: viewModel.loading,
          opacity: 0.5,
          color: Theme.of(context).colorScheme.background,
          child: Scaffold(
            key: viewModel.editProfileScaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: GradientText(
                'Edit Profile',
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
                  viewModel.resetEditProfile();
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
                      icon: const Icon(Icons.save_as_outlined),
                      onPressed: () {
                        viewModel.editProfile(context);
                      },
                      iconSize: 28.0,
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
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const ProfilePictureScreen()))
                        .then((value) => setState(() {
                      viewModel.imgLink = value;
                      if(viewModel.imgLink != null) {
                        viewModel.showSnackBar('Profile picture uploaded successfully.', context, error: false);
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
                        child: widget.user!.photoUrl!.isEmpty ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Center(
                            child: Text(
                              widget.user!.username![0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )) : viewModel.imgLink != null ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CachedNetworkImage(
                            imageUrl: viewModel.imgLink!,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      color: Colors.blue
                                  ),
                                ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ) : viewModel.image == null ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.user!.photoUrl!,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      color: Colors.blue
                                  ),
                                ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: FileImage(viewModel.image!),
                          ),
                        ),
                      ),
                    )
                  ),
                ),
                const SizedBox(
                  height: 10
                ),
                buildForm(viewModel, context)
              ],
            ),
          ),
        );
      },
      maximumSize: const Size(540.0, 960.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,);
  }
}