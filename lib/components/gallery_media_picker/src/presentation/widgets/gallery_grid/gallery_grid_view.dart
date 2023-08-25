// ignore_for_file: deprecated_member_use
import 'package:divine/components/gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../pages/gallery_media_picker_controller.dart';

typedef OnAssetItemClick = void Function(AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  final AssetPathEntity? path;

  final OnAssetItemClick? onAssetItemClick;

  final GalleryMediaPickerController provider;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    this.onAssetItemClick,
  }) : super(key: key);

  @override
  GalleryGridViewState createState() => GalleryGridViewState();
}

class GalleryGridViewState extends State<GalleryGridView> {
  static Map<int?, AssetEntity?> _createMap() {

    return {};
  }

  bool loaded = false;

  var cacheMap = _createMap();

  final scrolling = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.provider.assetCount > 0){
      setState(() {
        loaded = true;
      });
    }

    return widget.path != null
        ? NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: AnimatedBuilder(
              animation: widget.provider.assetCountNotifier,
              builder: (_, __) => Container(
                color: widget.provider.paramsModel.gridViewBackgroundColor,
                child: GridView.builder(
                  key: ValueKey(widget.path),
                  shrinkWrap: true,
                  padding: widget.provider.paramsModel.gridPadding ??
                      const EdgeInsets.all(0),
                  physics: widget.provider.paramsModel.gridViewPhysics ??
                      const ScrollPhysics(),
                  controller: widget.provider.paramsModel.gridViewController ??
                      ScrollController(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio:
                        widget.provider.paramsModel.childAspectRatio,
                    crossAxisCount: widget.provider.paramsModel.crossAxisCount,
                    mainAxisSpacing: 2.5,
                    crossAxisSpacing: 2.5,
                  ),

                  itemBuilder: (context, index) =>
                      _buildItem(context, index, widget.provider),
                  itemCount: widget.provider.assetCount,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: loaded == true ? Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25
                ),
                const Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Nothing to Show",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ) : Container()
    );
  }

  Widget _buildItem(
      BuildContext context, index, GalleryMediaPickerController provider) {

    return GestureDetector(
      onTap: () async {
        var asset = cacheMap[index];
        if (asset != null &&
            asset.type != AssetType.audio &&
            asset.type != AssetType.other) {
          asset = (await widget.path!
              .getAssetListRange(start: index, end: index + 1))[0];
          cacheMap[index] = asset;
          widget.onAssetItemClick?.call(asset, index);
        }
      },

      child: buildScrollItem(context, index, provider),
    );
  }

  Widget buildScrollItem(
      BuildContext context, int index, GalleryMediaPickerController provider) {
    final asset = cacheMap[index];
    if (asset != null) {

      return ThumbnailWidget(
        asset: asset,
        provider: provider,
        index: index,
      );
    } else {
      return FutureBuilder<List<AssetEntity>>(
        future: widget.path!.getAssetListRange(start: index, end: index + 1),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {

            return Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.provider.paramsModel.gridViewBackgroundColor,
            );
          }
          final asset = snapshot.data![0];
          cacheMap[index] = asset;

          return ThumbnailWidget(
            asset: asset,
            index: index,
            provider: provider,
          );
        },
      );
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      scrolling.value = false;
    } else if (notification is ScrollStartNotification) {
      scrolling.value = true;
    }

    return false;
  }

  @override
  void didUpdateWidget(GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      cacheMap.clear();
      scrolling.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) {

      return true;
    }
    if (other.runtimeType != runtimeType) {

      return false;
    }

    return other != this;
  }

}
