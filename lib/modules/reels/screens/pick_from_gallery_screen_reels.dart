import 'package:divine/plugins/video_editor/screens/video_editor.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../plugins/gallery_media_picker/src/data/model/gallery_params_model.dart';
import '../../../plugins/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';

class PickFromGalleryScreenReels extends StatefulWidget {
  const PickFromGalleryScreenReels({super.key});

  @override
  State<PickFromGalleryScreenReels> createState() =>
      _PickFromGalleryScreenReelsState();
}

class _PickFromGalleryScreenReelsState
    extends State<PickFromGalleryScreenReels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 2.0),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        title: GradientText(
          'Pick from Gallery',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ),
          colors: const [
            Colors.blue,
            Colors.purple,
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: GalleryMediaPicker(
        mediaPickerParams: MediaPickerParamsModel(
          gridViewController: ScrollController(
            initialScrollOffset: 0,
          ),
          singlePick: true,
          onlyVideos: true,
          onlyImages: false,
          appBarColor: Colors.black,
          thumbHeight: 380,
          gridViewPhysics: const ScrollPhysics(),
          appBarLeadingWidget: null,
          appBarHeight: 45,
          imageBackgroundColor: Colors.black,
          selectedBackgroundColor: Colors.transparent,
          selectedCheckColor: Colors.white,
          selectedCheckBackgroundColor: Colors.blue,
          stories: false,
        ),
        pathList: (path) {
          if (path.first.videoDuration > const Duration(minutes: 3) ||
              path.first.videoDuration < const Duration(seconds: 15)) {
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: 'Video should be between 15 seconds to 3 minutes.',
              ),
            );
          } else {
            Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => VideoEditor(file: path.first.file!)))
                .then((value) => Navigator.pop(context));
          }
        },
      ),
    );
  }
}
