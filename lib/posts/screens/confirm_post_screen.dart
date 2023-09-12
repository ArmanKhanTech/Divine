import 'dart:io';
import 'dart:ui';
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
  final List<File> postImages;

  const ConfirmSinglePostScreen({Key? key, required this.postImages}) : super(key: key);

  @override
  State<ConfirmSinglePostScreen> createState() => _ConfirmSinglePostScreenState();
}

class _ConfirmSinglePostScreenState extends State<ConfirmSinglePostScreen> with TickerProviderStateMixin{
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
                height: 220,
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
                        if(mounted){
                          for(int i = 0; i < widget.postImages.length; i++){
                            await widget.postImages[i].delete();
                          }
                          await viewModel.resetPost();
                          Navigator.pop(c, true);
                          Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(builder: (_) => const MainScreen()), (route) => false);
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
              padding: const EdgeInsets.only(bottom: 2.0),
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
            ),
            title: GradientText(
              'New Post',
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
          ),
          backgroundColor: Colors.black,
          body: ListView(
            children: [
              const SizedBox(height: 10.0),
              SizedBox(
                height: MediaQuery.of(context).size.width,
                child: widget.postImages.length > 1 ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.postImages.length,
                  itemBuilder: (BuildContext context, int index) {

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.9,
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(widget.postImages[index]),
                          fit: BoxFit.fitWidth,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                        child: Stack(alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10.0,
                                  sigmaY: 10.0,
                                ),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                            ),
                            viewModel.mediaUrl!.isNotEmpty ? CustomImage(
                              imageUrl: viewModel.mediaUrl![index],
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.contain,
                            ) :  Image.file(
                              widget.postImages[index],
                              key: UniqueKey(),
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    );
                  },
                ) : Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(widget.postImages[0]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      child: Stack(alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),
                          viewModel.mediaUrl!.isNotEmpty ? CustomImage(
                            imageUrl: viewModel.mediaUrl![0],
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                          ) :  Image.file(
                            widget.postImages[0],
                            key: UniqueKey(),
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    )
                ),
              ),
              const SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: SizedBox(
                  height: 65.0,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white, fontSize: 18.0, height: 1.2),
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Caption',
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                      hintText: 'Eg. This is very beautiful place!',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 18.0, height: 1.2),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
                          )
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
                          )
                      ),
                      isDense: true,                      // Added this
                      contentPadding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      isCollapsed: true,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    maxLines: null,
                    onChanged: (val) => viewModel.setDescription(val),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: SizedBox(
                  height: 65.0,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    controller: viewModel.locationTEC,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0, height: 1.2
                    ),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Location',
                      labelStyle: const TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                      hintText: 'Eg. New York',
                      hintStyle: const TextStyle(color: Colors.white70, fontSize: 18.0, height: 1.2),
                      enabled: true,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
                          )
                      ),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
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
                      contentPadding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      isCollapsed: true,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    maxLines: null,
                    onChanged: (val) => viewModel.setLocation(val),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          viewModel.mentions.isEmpty ? 'Add all the people you want to mention in this post here.'
                              : 'You are mentioning ${viewModel.mentions.length} ${viewModel.mentions.length == 1 ? 'person' : 'people'} in this post.',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18.0,
                            height: 1.2
                        ),
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          labelText: 'Mentions',
                          labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                          hintText: 'Eg. @john @doe',
                          hintStyle: TextStyle(color: Colors.white70, fontSize: 18.0, height: 1.2),
                          enabled: true,
                          isDense: true,                      // Added this
                          contentPadding: EdgeInsets.only(
                            bottom: 10,
                            top: 10,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          isCollapsed: true,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Colors.white,
                        maxLines: null,
                        onChanged: (val) {
                          if(val.isNotEmpty){
                            viewModel.setMentions(val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: SizedBox(
                  height: 65.0,
                  child:  TextFormField(
                    style: const TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Hashtags',
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                      hintText: 'Eg. #nature #beauty',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 18.0, height: 1.2),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
                          )
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)
                          )
                      ),
                      isDense: true,                      // Added this
                      contentPadding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      isCollapsed: true,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    maxLines: null,
                    onChanged: (val) {
                      if(val.isNotEmpty){
                        viewModel.setHashTags(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
                child: SizedBox(
                  height: 40.0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                    child: const Padding(
                        padding: EdgeInsets.only(
                            bottom: 2
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                    ),
                    onPressed: () async {
                      await viewModel.uploadPost(context, images: widget.postImages);
                      await viewModel.resetPost();
                      for(int i = 0; i < widget.postImages.length; i++){
                        await widget.postImages[i].delete();
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (_) => const MainScreen()), (route) => false);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class NewTextField extends StatelessWidget {
  const NewTextField({
    super.key,
    required this.name,
    this.onDelete, required this.viewModel,
  });

  final PostsViewModel viewModel;
  final String name;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                height: 1.2
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: name,
                labelStyle: const TextStyle(color: Colors.blue, fontSize: 18.0, height: 1.2),
                hintText: 'Eg. @john',
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 18.0, height: 1.2),
                enabled: true,
                isDense: true,                      // Added this
                contentPadding: const EdgeInsets.only(
                  bottom: 10,
                  top: 10,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                isCollapsed: true,
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.blue, size: 25),
                      onPressed: () {
                        if(controller.text.isNotEmpty){
                          viewModel.setMentions(controller.text);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 25),
                      onPressed: onDelete,
                    ),
                  ],
                )
              ),
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.white,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}