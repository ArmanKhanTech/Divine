import 'dart:io';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../src/controller.dart';
import '../src/export/ffmpeg_export_config.dart';
import '../src/models/cover_style.dart';
import '../src/widgets/cover/cover_selection.dart';
import '../src/widgets/cover/cover_viewer.dart';
import '../src/widgets/crop/crop_grid.dart';
import '../src/widgets/export_result.dart';
import '../src/widgets/trim/trim_slider.dart';
import '../src/widgets/trim/trim_timeline.dart';
import 'crop_screen.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final exportingProgress = ValueNotifier<double>(0.0);
  final isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 15),
    maxDuration: const Duration(seconds: 180),
  );

  @override
  void initState() {
    super.initState();
    controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      Navigator.pop(context);
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

        showDialog(
          context: context,
          builder: (_) => VideoResultPopup(video: file),
        );
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
                      child: Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CropGridViewer.preview(
                                        controller: controller),
                                    AnimatedBuilder(
                                      animation: controller.video,
                                      builder: (_, __) => AnimatedOpacity(
                                        opacity:
                                        controller.isPlaying ? 0 : 1,
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
                                  ],
                                ),
                                CoverViewer(controller: controller)
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                const TabBar(
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.content_cut, color: Colors.white)),
                                          Text('Trim', style: TextStyle(color: Colors.white))
                                        ]),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(5),
                                            child:
                                            Icon(Icons.video_label, color: Colors.white)),
                                        Text('Cover', style: TextStyle(color: Colors.white))
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
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
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22, color: Colors.white),
            Expanded(
              child: IconButton(
                onPressed: () => controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left, color: Colors.white),
                tooltip: 'Rotate Anticlockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: controller),
                  ),
                ),
                icon: const Icon(Icons.crop, color: Colors.white),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22, color: Colors.white),
            IconButton(
              onPressed: exportVideo,
              icon: const Icon(
                CupertinoIcons.check_mark_circled,
                color: Colors.blue,
              )
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
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {

    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
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
