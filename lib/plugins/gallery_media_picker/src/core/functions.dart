import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:oktoast/oktoast.dart';

import '../presentation/pages/gallery_media_picker_controller.dart';
import '../presentation/widgets/select_album_path/dropdown.dart';
import '../presentation/widgets/select_album_path/overlay_drop_down.dart';

class GalleryFunctions {
  static FeatureController<T> showDropDown<T>({
    required BuildContext context,
    required DropdownWidgetBuilder<T> builder,
    required TickerProvider tickerProvider,
    double? height,
    Duration animationDuration = const Duration(milliseconds: 250),
  }) {
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );

    final completer = Completer<T?>();
    var isReply = false;

    OverlayEntry? entry;

    void close(T? value) async {
      if (isReply) {
        return;
      }
      isReply = true;
      animationController.animateTo(0).whenCompleteOrCancel(() async {
        await Future.delayed(const Duration(milliseconds: 16));
        completer.complete(value);
        entry?.remove();
      });
    }

    entry = OverlayEntry(
        builder: (context) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => close(null),
              child: OverlayDropDown(
                  height: height!,
                  close: close,
                  animationController: animationController,
                  builder: builder),
            ));

    Overlay.of(context).insert(entry);
    animationController.animateTo(1);

    return FeatureController(
      completer,
      close,
    );
  }

  static onPickMax(GalleryMediaPickerController provider) {
    provider.onPickMax
        .addListener(() => showToast("Already picked ${provider.max} images."));
  }

  static getPermission(setState, GalleryMediaPickerController provider) async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));

    if (result.isAuth) {
      provider.setAssetCount();
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList(setState, provider);
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList(setState, provider);
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  static _refreshPathList(setState, GalleryMediaPickerController provider) {
    PhotoManager.getAssetPathList(
            type: provider.paramsModel.onlyVideos
                ? RequestType.video
                : provider.paramsModel.onlyImages
                    ? RequestType.image
                    : RequestType.image)
        .then((pathList) {
      Future.delayed(Duration.zero, () {
        setState(() {
          provider.resetPathList(pathList);
        });
      });
    });
  }

  static Future getFile(AssetEntity asset) async {
    var file = await asset.file;
    return file!.path;
  }
}

class FeatureController<T> {
  final Completer<T?> completer;
  final ValueSetter<T?> close;
  FeatureController(this.completer, this.close);
  Future<T?> get closed => completer.future;
}
