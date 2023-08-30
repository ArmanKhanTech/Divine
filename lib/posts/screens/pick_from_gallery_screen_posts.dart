import 'dart:io';
import 'package:camera/camera.dart';
import 'package:divine/view_models/user/gallery_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../components/gallery_media_picker/src/data/models/gallery_params_model.dart';
import '../../components/gallery_media_picker/src/data/models/picked_asset_model.dart';
import '../../components/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';
import '../../view_models/screens/posts_view_model.dart';

class PickFromGalleryScreenPosts extends StatefulWidget {
  const PickFromGalleryScreenPosts({super.key});

  @override
  State<PickFromGalleryScreenPosts> createState() => _PickFromGalleryScreenPostsState();
}

class _PickFromGalleryScreenPostsState extends State<PickFromGalleryScreenPosts> {
  List<XFile> imageList = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

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
      body: Consumer<GalleryViewModel>(
        builder: (context, galleryViewModel, child) {
          return Stack(
            children: [
              GalleryMediaPicker(
                mediaPickerParams: MediaPickerParamsModel(
                  gridViewController: ScrollController(
                    initialScrollOffset: 0,
                  ),
                  maxPickImages: 5,
                  thumbnailQuality: 200,
                  singlePick: false,
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
                // TODO : continue here
                pathList: (List<PickedAssetModel> paths) {
                  setState(() {
                    galleryViewModel.pickedFile = paths;
                  });
                  if(galleryViewModel.exceedsLimit) {
                    galleryViewModel.showSnackBar('Image size exceeds 4MB.', context);
                  }
                },
              ),
              galleryViewModel.pickedFile.isNotEmpty ? Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    if(galleryViewModel.pickedFile.isNotEmpty) {
                      if(galleryViewModel.pickedFile.length == 1){
                        XFile file = XFile(galleryViewModel.pickedFile.first.path.toString());
                        viewModel.uploadPostSingleImage(image: file, context: context);
                      } else {
                        List<XFile> images = [];
                        for(int i = 0; i < galleryViewModel.pickedFile.length; i++){
                          images.add(XFile(galleryViewModel.pickedFile[i].path.toString()));
                        }
                        viewModel.uploadPostMultipleImages(images: images, context: context);
                      }
                    }
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.check),
                ),
              ) : Container(),
            ],
          );
        },
      ),
    );
  }
}