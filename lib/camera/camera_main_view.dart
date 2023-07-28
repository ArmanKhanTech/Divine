import 'package:better_open_file/better_open_file.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:divine/camera/utils/file_utils.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/material.dart';

class CameraMainView extends StatefulWidget{
  const CameraMainView({super.key});

  @override
  State<CameraMainView> createState() => _CameraMainViewState();
}

class _CameraMainViewState extends State<CameraMainView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photo(
            pathBuilder: () => path(CaptureMode.photo),
          ),
          enablePhysicalButton: true,
          flashMode: FlashMode.auto,
          onMediaTap: (mediaCapture) {
            OpenFile.open(mediaCapture.filePath);
          },
          sensor: Sensors.front,
          enableAudio: false,
          progressIndicator: circularProgress(context, const Color(0xFF03A9F4)),
          imageAnalysisConfig: AnalysisConfig(
            androidOptions: const AndroidAnalysisOptions.nv21(
              width: 250,
            ),
            autoStart: true,
            maxFramesPerSecond: 20,
          ),
        ),
      ),
    );
  }
}