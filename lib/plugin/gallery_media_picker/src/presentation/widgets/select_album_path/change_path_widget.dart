import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../data/models/gallery_params_model.dart';
import '../../pages/gallery_media_picker_controller.dart';

class ChangePathWidget extends StatefulWidget {
  final GalleryMediaPickerController provider;
  final ValueSetter<AssetPathEntity> close;
  final MediaPickerParamsModel mediaPickerParams;

  const ChangePathWidget(
      {Key? key,
      required this.provider,
      required this.close,
      required this.mediaPickerParams})
      : super(key: key);

  @override
  ChangePathWidgetState createState() => ChangePathWidgetState();
}

class ChangePathWidgetState extends State<ChangePathWidget> {
  GalleryMediaPickerController get provider => widget.provider;

  ScrollController? controller;
  double itemHeight = 65;

  @override
  void initState() {
    final index = provider.pathList.indexOf(provider.currentAlbum!);
    controller = ScrollController(initialScrollOffset: itemHeight * index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1)),
      child: Material(
        color: Colors.transparent,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();

            return false;
          },
          child: MediaQuery.removePadding(
            removeTop: true,
            removeBottom: true,
            context: context,
            child: ListView.builder(
              controller: controller,
              itemCount: provider.pathList.length,
              itemBuilder: buildItem,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.close.call(item),
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: widget.mediaPickerParams.albumTextColor,
                    fontSize: 18),
              ),
            ),
          ),
          Positioned(
              height: 1,
              bottom: 0,
              right: 0,
              left: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
