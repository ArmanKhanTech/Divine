import 'dart:io';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../components/custom_image.dart';
import '../../screens/main_screen.dart';
import '../../stories/stories_editor/presentation/widgets/animated_on_tap_button.dart';
import '../../view_models/screens/posts_view_model.dart';
import '../../widgets/progress_indicators.dart';

class ConfirmSinglePostScreen extends  StatefulWidget{
  final File? postImage;

  const ConfirmSinglePostScreen({Key? key, required this.postImage}) : super(key: key);

  @override
  State<ConfirmSinglePostScreen> createState() => _ConfirmSinglePostScreenState();
}

class _ConfirmSinglePostScreenState extends State<ConfirmSinglePostScreen> {
  @override
  Widget build(BuildContext context) {
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
                height: 240,
                color: Colors.black.withOpacity(0.15),
                blur: 5,
                padding: const EdgeInsets.all(20),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Cancel?',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "If you go back now, you'll lose all the edits you've made.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                          letterSpacing: 0.1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    AnimatedOnTapButton(
                      onTap: () async {
                        await viewModel.resetPost();
                        if(mounted){
                          widget.postImage!.delete();
                          Navigator.pop(c, true);
                          Navigator.pop(context);
                        }
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
                        color: Colors.white,
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

    // TODO: Search user while tagging
    return WillPopScope(
      onWillPop: () async {
        await exitDialog(viewModel: viewModel);
        return false;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        opacity: 0.5,
        color: Colors.black,
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
              color: Colors.white,
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
            ),
            title: GradientText(
              'Upload Post',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
              ), colors: const [
              Colors.blue,
              Colors.purple,
            ],
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadSinglePost(context, widget.postImage!);
                  await viewModel.resetPost();
                  widget.postImage!.delete();
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(builder: (_) => const MainScreen()), (route) => false);
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                    right: 20.0,
                    top: 5,
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 30.0,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Colors.black,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.0,
                  )
                ),
                clipBehavior: Clip.hardEdge,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: viewModel.imgLink != null ? CustomImage(
                    imageUrl: viewModel.imgLink,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ) : widget.postImage == null ? const Center(
                    child: Text(
                      'Upload a Photo',
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Raleway',
                        fontSize: 18.0,
                      ),
                    ),
                  ) : Image.file(
                    widget.postImage!,
                    key: UniqueKey(),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ),
                )
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 60.0,
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Caption',
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintText: 'Eg. This is very beautiful place!',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)
                          )
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)
                          )
                      ),
                    isDense: true,                      // Added this
                    contentPadding: EdgeInsets.all(15),
                    isCollapsed: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.white,
                  maxLines: null,
                  onChanged: (val) => viewModel.setDescription(val),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 60.0,
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  controller: viewModel.locationTEC,
                  style: const TextStyle(
                      color: Colors.white
                  ),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Location',
                    labelStyle: const TextStyle(color: Colors.blue, fontSize: 18.0),
                    hintText: 'Eg. New York',
                    hintStyle: const TextStyle(color: Colors.white70),
                    enabled: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(30.0)
                        )
                    ),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(30.0)
                        )
                    ),
                    suffixIcon: IconButton(
                      tooltip: "Use your current location",
                      icon: const Icon(
                        CupertinoIcons.map_pin_ellipse,
                        size: 25,
                      ),
                      iconSize: 30.0,
                      color: Colors.blue,
                      onPressed: () => viewModel.getLocation(),
                    ),
                    isDense: true,                      // Added this
                    contentPadding: const EdgeInsets.all(15),
                    isCollapsed: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.white,
                  maxLines: null,
                  onChanged: (val) => viewModel.setLocation(val),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 60.0,
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.pink,
                  ),
                  decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Mentions',
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintText: 'Eg. @john @jane',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)
                          )
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)
                          )
                      ),
                    isDense: true,                      // Added this
                    contentPadding: EdgeInsets.all(15),
                    isCollapsed: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.white,
                  maxLines: null,
                  onChanged: (val) => viewModel.setMentions(val),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                 height: 60.0,
                 child:  TextFormField(
                   style: const TextStyle(color: Colors.blue),
                   decoration: const InputDecoration(
                       alignLabelWithHint: true,
                       labelText: 'Hashtags',
                       labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                       hintText: 'Eg. #nature #beauty',
                       hintStyle: TextStyle(color: Colors.white70),
                       enabled: true,
                       enabledBorder: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.blue),
                           borderRadius: BorderRadius.all(Radius.circular(30.0)
                           )
                       ),
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.blue, width: 0.0),
                           borderRadius: BorderRadius.all(Radius.circular(30.0)
                           )
                       ),
                     isDense: true,                      // Added this
                     contentPadding: EdgeInsets.all(15),
                     isCollapsed: true,
                   ),
                   textAlignVertical: TextAlignVertical.center,
                   cursorColor: Colors.white,
                   maxLines: null,
                   onChanged: (val) => viewModel.setHashtags(val),
               ),
              )
            ],
          ),
        ),
      ),
    );
  }
}