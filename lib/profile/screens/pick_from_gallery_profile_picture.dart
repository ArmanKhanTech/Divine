import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/gallery_media_picker/src/data/models/gallery_params_model.dart';
import '../../components/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';

class PickFromGalleryProfilePicture extends StatefulWidget {
  const PickFromGalleryProfilePicture({super.key});

  @override
  State<PickFromGalleryProfilePicture> createState() => _PickFromGalleryProfilePictureState();
}

class _PickFromGalleryProfilePictureState extends State<PickFromGalleryProfilePicture> {
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
          'Select',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ), colors: const [
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
          maxPickImages: 1,
          thumbnailQuality: 200,
          singlePick: true,
          onlyImages: true,
          appBarColor: Colors.black,
          gridViewPhysics: const ScrollPhysics(),
          appBarLeadingWidget: null,
          appBarHeight: 45,
          imageBackgroundColor: Colors.black,
          selectedBackgroundColor: Colors.transparent,
          selectedCheckColor: Colors.white,
          selectedCheckBackgroundColor: Colors.blue,
        ),
        pathList: (path) {
          final file = File(path.first.path.toString());
          int sizeInBytes = file.lengthSync();
          double sizeInMb = sizeInBytes / (1024 * 1024);
          if (sizeInMb > 4){
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: 'File size is too large ( > 2 MB)',
              ),
            );
          } else{
            XFile file = XFile(path.first.path.toString());
            Navigator.of(context).pop(file);
          }
        },
      ),
    );
  }
}