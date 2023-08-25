import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AudioViewModel extends ChangeNotifier{
  bool audioLoading = false, audioLoaded = false;

  late File audioFile;

  Duration? audioDuration = Duration.zero;

  double start = 0.0, end = 0.0;

  String audioName = '';

  void resetAudio() {
    audioLoading = false;
    audioLoaded = false;
    audioFile = File('');
    audioDuration = Duration.zero;
    start = 0.0;
    end = 0.0;
    audioName = '';
    notifyListeners();
  }

  @override
  void dispose() {
    resetAudio();
    super.dispose();
  }

  Future<String> chooseAudio(BuildContext context) async {
    audioLoading = true;
    notifyListeners();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
    );

    if (result != null) {
      audioFile = File(result.files.single.path!);
      audioName = result.files.single.name;
    } else {
      showSnackBar('No audio selected.', context, error: true);
    }
    audioLoaded = true;
    notifyListeners();

    return audioFile.path;
  }

  void setStart(double value) {
    start = value;
    notifyListeners();
  }

  void setEnd(double value) {
    end = value;
    notifyListeners();
  }

  void setAudioDuration(Duration? duration) {
    audioDuration = duration;
    notifyListeners();
  }

  showSnackBar(String msg, context, {required bool error}) {
    showTopSnackBar(
      Overlay.of(context),
      error == false ? CustomSnackBar.success(
        message: msg,
      ) : CustomSnackBar.error(
        message: msg,
      ),
    );
  }
}