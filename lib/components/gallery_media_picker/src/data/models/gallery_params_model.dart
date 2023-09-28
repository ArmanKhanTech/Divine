import 'package:flutter/material.dart';

class MediaPickerParamsModel {
  MediaPickerParamsModel({
    this.maxPickImages = 2,
    this.stories = false,
    this.singlePick = true,
    this.appBarColor = Colors.black,
    this.albumBackGroundColor = Colors.black,
    this.albumDividerColor = Colors.white,
    this.albumTextColor = Colors.white,
    this.appBarIconColor,
    this.appBarTextColor = Colors.white,
    this.crossAxisCount = 3,
    this.gridViewBackgroundColor = Colors.black54,
    this.childAspectRatio = 0.5,
    this.appBarLeadingWidget,
    this.appBarHeight = 100,
    this.imageBackgroundColor = Colors.white,
    this.gridPadding,
    this.gridViewController,
    this.gridViewPhysics,
    this.selectedBackgroundColor = Colors.white,
    this.selectedCheckColor = Colors.white,
    this.thumbnailBoxFix = BoxFit.cover,
    this.selectedCheckBackgroundColor = Colors.white,
    this.onlyImages = true,
    this.onlyVideos = false,
    this.thumbnailQuality = 200,
    this.thumbHeight = 200,
  });

  final int maxPickImages;

  final bool singlePick;

  final Color appBarColor;

  final Color appBarTextColor;
  final Color? appBarIconColor;
  final Color gridViewBackgroundColor;
  final Color imageBackgroundColor;
  final Color albumBackGroundColor;
  final Color albumTextColor;
  final Color albumDividerColor;

  final int crossAxisCount;

  final double childAspectRatio;
  final double? thumbHeight;

  final Widget? appBarLeadingWidget;

  final double appBarHeight;

  final EdgeInsets? gridPadding;

  final ScrollPhysics? gridViewPhysics;

  final ScrollController? gridViewController;

  final Color selectedBackgroundColor;
  final Color selectedCheckColor;

  final BoxFit thumbnailBoxFix;

  final Color selectedCheckBackgroundColor;

  final bool onlyVideos;
  final bool onlyImages;

  final int thumbnailQuality;

  final bool stories;
}
