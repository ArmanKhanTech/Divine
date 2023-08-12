import 'dart:io';
import 'package:divine/reels/video_editor/screens/text_overlay_screen.dart';
import 'package:divine/reels/video_editor/src/models/trim_style.dart';
import 'package:divine/reels/video_editor/src/widgets/crop/crop_grid.dart';
import 'package:divine/reels/video_editor/src/widgets/text/text_overlay_bottom_sheet.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../src/utilities/controller.dart';
import '../src/export/ffmpeg_export_config.dart';
import '../src/models/cover_style.dart';
import '../src/widgets/cover/cover_selection.dart';
import '../src/widgets/cover/cover_viewer.dart';
import '../src/widgets/export_result.dart';
import '../src/widgets/trim/trim_slider.dart';
import '../src/widgets/trim/trim_timeline.dart';
import 'crop_screen.dart';
import 'filters_screen.dart';

class VideoEditor extends StatefulWidget {
  final File file;

  const VideoEditor({super.key, required this.file});

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final exportingProgress = ValueNotifier<double>(0.0);
  final isExporting = ValueNotifier<bool>(false);

  final double height = 60;

  Offset offset = Offset.zero;

  late final VideoEditorController controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 15),
    maxDuration: const Duration(seconds: 180),
    trimStyle: TrimSliderStyle(
       onTrimmedColor: Colors.blue,
       onTrimmingColor: Colors.blue,
       iconColor: Colors.white,
    )
  );

  @override
  void initState() {
    super.initState();
    controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      Navigator.pop(context, true);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    exportingProgress.dispose();
    isExporting.dispose();
    controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  showSnackBar(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.blue,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        )
    ));
  }

  void exportVideo() async {
    controller.setTextx1(controller.textx1);
    controller.setTexty1(controller.texty1);

    exportingProgress.value = 0;
    isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      controller,
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) => showSnackBar("Error on export video :("),
      onCompleted: (file) {
        isExporting.value = false;
        if (!mounted) return;

        /*showDialog(
          context: context,
          builder: (_) => VideoResultPopup(video: file),
        );*/
      },
    );
  }

  void exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      showSnackBar("Error on cover exportation initialization.");

      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => showSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    void showBottomDialog() {
      controller.textOverlay == true ? showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          builder: (BuildContext context) {

            return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextOverlayBottomSheet(
                    controller: controller,
                    onUpdate: () {
                      setState(() {});
                    },
                  ),
                )
            );
          }
      ) : null;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: controller.initialized ? SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  topNavBar(),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      animationDuration: Duration.zero,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ColorFiltered(
                                          colorFilter: controller.colorFilter,
                                          child: CropGridViewer.preview(controller: controller),
                                        ),
                                        AnimatedBuilder(
                                          animation: controller.video,
                                          builder: (_, __) => AnimatedOpacity(
                                            opacity: controller.isPlaying ? 0 : 1,
                                            duration: kThemeAnimationDuration,
                                            child: GestureDetector(
                                              onTap: controller.video.play,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration:
                                                const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        controller.textOverlay == true ? Positioned(
                                          left: offset.dx,
                                          top: offset.dy,
                                          child: GestureDetector(
                                            onPanUpdate: (details) {
                                              setState(() {
                                                offset = Offset(
                                                    offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                                              });
                                              controller.setTextx1(offset.dx);
                                              controller.setTexty1(offset.dy);
                                            },
                                            onTap: () {
                                              showBottomDialog();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: controller.textBgColor,
                                              ),
                                              child: Text(
                                                controller.text,
                                                textAlign: controller.textAlign,
                                                style: TextStyle(
                                                  fontSize: controller.textSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: controller.textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ColorFiltered(
                                      colorFilter: controller.colorFilter,
                                      child: CoverViewer(controller: controller),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                            height: 180,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black,
                                  ),
                                  child: TabBar(
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.black,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blue,
                                    ),
                                    tabs: const [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(Icons.content_cut, color: Colors.white)),
                                            Text('Trim', style: TextStyle(color: Colors.white))
                                          ]),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.video_label, color: Colors.white)),
                                          Text('Cover', style: TextStyle(color: Colors.white))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: _trimSlider(),
                                      ),
                                      _coverSelection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: isExporting,
                            builder: (_, bool export, Widget? child) =>
                                AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                            child: AlertDialog(
                              title: ValueListenableBuilder(
                                valueListenable: exportingProgress,
                                builder: (_, double value, __) => Text(
                                  "Exporting video ${(value * 100).ceil()}%",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ) : Center(child: circularProgress(context, const Color(0xffF2F2F2))),
      ),
    );
  }

  Widget topNavBar() {

    return SafeArea(
      child: SizedBox(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                tooltip: 'Leave Editor',
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.blue,
            ),
            Expanded(
              child: IconButton(
                onPressed: () => controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                tooltip: 'Rotate Clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropScreen(controller: controller),
                  ),
                ),
                icon: const Icon(Icons.crop, color: Colors.white),
                tooltip: 'Crop',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.music_note, color: Colors.white),
                tooltip: 'Audio',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => TextOverlayScreen(controller: controller),
                  ),
                ).then((value) {
                  setState(() {});
                }),
                icon: const Icon(Icons.text_fields, color: Colors.white),
                tooltip: 'Text',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => FiltersScreen(controller: controller),
                      ),
                    ).then((value) {
                      setState(() {});
                    }),
                icon: const Icon(Icons.filter, color: Colors.white),
                tooltip: 'Filter',
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.blue,
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(
              onPressed: exportVideo,
              icon: const Icon(
                CupertinoIcons.checkmark_alt,
                color: Colors.blue,
              )
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {

    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          controller,
          controller.video,
        ]),
        builder: (_, __) {
          final int duration = controller.videoDuration.inSeconds;
          final double pos = controller.trimPosition * duration;

          return Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 5
            ),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${formatter(controller.startTrim)} - ', style: const TextStyle(color: Colors.white)),
                  Text(formatter(controller.endTrim), style: const TextStyle(color: Colors.white)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        child: TrimSlider(
          controller: controller,
          height: height,
          hasHaptic: true,
          child: TrimTimeline(
            controller: controller,
            padding: const EdgeInsets.only(top: 10),
            quantity: 8,
          ),
        ),
      ),
    ];
  }

  Widget _coverSelection() {

    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: CoverSelection(
            controller: controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {

              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
