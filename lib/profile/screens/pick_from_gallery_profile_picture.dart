import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../components/gallery_media_picker/src/data/models/gallery_params_model.dart';
import '../../components/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';
import '../../view_models/screens/posts_view_model.dart';

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
        ),
        pathList: (path) {
          final file = File(path.first.path.toString());
          int sizeInBytes = file.lengthSync();
          double sizeInMb = sizeInBytes / (1024 * 1024);
          if (sizeInMb > 4){
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File size is too large ( > 2 MB)', textAlign: TextAlign.center, style: TextStyle(fontSize: 15),), backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2), padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                )
            ));
          } else{
            // TODO: Implement multi image upload
            XFile file = XFile(path.first.path.toString());
            Navigator.of(context).pop(file);
          }
        },
      ),
    );
  }
}