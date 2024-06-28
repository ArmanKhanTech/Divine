// ignore_for_file: unnecessary_null_comparison
import 'package:divine/widget/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/functions.dart';
import '../../data/model/gallery_params_model.dart';
import '../../data/model/picked_asset_model.dart';
import '../widget/gallery_grid/gallery_grid_view.dart';
import '../widget/select_album_path/current_path_selector.dart';

import 'gallery_media_picker_controller.dart';

class GalleryMediaPicker extends StatefulWidget {
  final MediaPickerParamsModel mediaPickerParams;

  final Function(List<PickedAssetModel> path) pathList;

  const GalleryMediaPicker({
    Key? key,
    required this.mediaPickerParams,
    required this.pathList,
  }) : super(key: key);

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  final GalleryMediaPickerController provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    getPermission();
    provider.paramsModel = widget.mediaPickerParams;
  }

  void getPermission() {
    GalleryFunctions.getPermission(setState, provider);
    GalleryFunctions.onPickMax(provider);
  }

  @override
  void dispose() {
    if (mounted) {
      PhotoManager.stopChangeNotify();
      provider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider.max = widget.mediaPickerParams.maxPickImages;
    provider.singlePickMode = widget.mediaPickerParams.singlePick;

    return OKToast(
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: Column(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  alignment: Alignment.center,
                  child: SelectedPathDropdownButton(
                    provider: provider,
                    mediaPickerParams: widget.mediaPickerParams,
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: provider != null
                      ? AnimatedBuilder(
                          animation: provider.currentAlbumNotifier,
                          builder: (BuildContext context, child) =>
                              GalleryGridView(
                            provider: provider,
                            path: provider.currentAlbum,
                            onAssetItemClick: (asset, index) async {
                              provider.pickEntity(asset);
                              GalleryFunctions.getFile(asset)
                                  .then((value) async {
                                provider.pickPath(PickedAssetModel(
                                  id: asset.id,
                                  path: value,
                                  type: asset.typeInt == 1 ? 'image' : 'video',
                                  videoDuration: asset.videoDuration,
                                  createDateTime: asset.createDateTime,
                                  latitude: asset.latitude,
                                  longitude: asset.longitude,
                                  thumbnail: await asset.thumbnailData,
                                  height: asset.height,
                                  width: asset.width,
                                  orientationHeight: asset.orientatedHeight,
                                  orientationWidth: asset.orientatedWidth,
                                  orientationSize: asset.orientatedSize,
                                  file: await asset.file,
                                  modifiedDateTime: asset.modifiedDateTime,
                                  title: asset.title,
                                  size: asset.size,
                                ));
                                widget.pathList(provider.pickedFile);
                              });
                            },
                          ),
                        )
                      : Center(
                          child: circularProgress(context, Colors.white),
                        ),
                ),
              ))
            ],
          )),
    );
  }
}
