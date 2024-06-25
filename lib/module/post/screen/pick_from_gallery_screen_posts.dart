import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../plugin/gallery_media_picker/src/data/models/gallery_params_model.dart';
import '../../../plugin/gallery_media_picker/src/data/models/picked_asset_model.dart';
import '../../../plugin/gallery_media_picker/src/presentation/pages/gallery_media_picker.dart';
import '../../../viewmodel/screens/posts_view_model.dart';
import '../../../widget/progress_indicators.dart';

class PickFromGalleryScreenPosts extends StatefulWidget {
  const PickFromGalleryScreenPosts({super.key});

  @override
  State<PickFromGalleryScreenPosts> createState() =>
      PickFromGalleryScreenPostsState();
}

class PickFromGalleryScreenPostsState
    extends State<PickFromGalleryScreenPosts> {
  List<PickedAssetModel> pickedImages = [];

  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    void showSnackBar(String message, BuildContext context) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.pop(context);
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
      body: Stack(
        children: [
          GalleryMediaPicker(
            mediaPickerParams: MediaPickerParamsModel(
              gridViewController: ScrollController(
                initialScrollOffset: 0,
              ),
              maxPickImages: 5,
              singlePick: false,
              onlyImages: true,
              appBarColor: Colors.black,
              thumbHeight: 140,
              childAspectRatio: 1 / 1,
              gridViewPhysics: const ScrollPhysics(),
              appBarLeadingWidget: null,
              appBarHeight: 45,
              imageBackgroundColor: Colors.black,
              selectedBackgroundColor: Colors.transparent,
              selectedCheckColor: Colors.white,
              selectedCheckBackgroundColor: Colors.blue,
              stories: false,
            ),
            pathList: (List<PickedAssetModel> paths) {
              pickedImages = paths;
            },
          ),
          Positioned(
            bottom: 5,
            right: 15,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.blue,
                ),
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                    onTap: () async {
                      if (pickedImages.isNotEmpty) {
                        loading.value = true;
                        if (pickedImages.length == 1) {
                          XFile file =
                              XFile(pickedImages.first.path.toString());
                          await viewModel.uploadPostSingleImage(
                              image: file, context: context);
                        } else {
                          List<XFile> images = [];
                          for (int i = 0; i < pickedImages.length; i++) {
                            images.add(XFile(pickedImages[i].path.toString()));
                          }
                          await viewModel.uploadPostMultipleImages(
                              images: images, context: context);
                        }
                        loading.value = false;
                      } else {
                        showSnackBar('Please select an image.', context);
                      }
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: loading,
                      builder: (context, value, child) {
                        return Center(
                          child: !value
                              ? const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 35,
                                )
                              : Center(
                                  child: SizedBox(
                                    height: 35,
                                    width: 35,
                                    child: circularProgress(
                                        context, Colors.white,
                                        size: 30.0),
                                  ),
                                ),
                        );
                      },
                    ))),
          ),
        ],
      ),
    );
  }
}
