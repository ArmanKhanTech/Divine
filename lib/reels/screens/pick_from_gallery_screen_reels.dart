import 'package:divine/reels/video_editor/screens/video_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../components/gallery_media_picker/src/data/models/gallery_params_model.dart';
import '../../components/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';

class PickFromGalleryScreenReels extends StatefulWidget{
  const PickFromGalleryScreenReels({super.key});

  @override
  State<PickFromGalleryScreenReels> createState () => _PickFromGalleryScreenReelsState();
}

class _PickFromGalleryScreenReelsState extends State<PickFromGalleryScreenReels>{
  @override
  Widget build(BuildContext context){

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
          thumbnailQuality: 200,
          singlePick: true,
          onlyVideos: true,
          onlyImages: false,
          appBarColor: Colors.black,
          gridViewPhysics: const ScrollPhysics(),
          appBarLeadingWidget: null,
          appBarHeight: 45,
          imageBackgroundColor: Colors.black,
          selectedBackgroundColor: Colors.transparent,
          selectedCheckColor: Colors.blue,
          selectedCheckBackgroundColor: Colors.transparent,
        ),
        pathList: (path) {
          if (path.first.videoDuration > const Duration(minutes: 3) || path.first.videoDuration < const Duration(seconds: 15)){
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video should be between 15 seconds to 3 minutes.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15),), backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2), padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                )
            ));
          } else{
            Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => VideoEditor(file: path.first.file!)
                )
            ).then((value) => Navigator.pop(context));
          }
        },
      ),
    );
  }
}