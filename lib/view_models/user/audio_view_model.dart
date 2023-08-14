import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioViewModel extends ChangeNotifier{
  bool audioLoading = false, audioLoaded = false;

  late File audioFile;

  final player = AudioPlayer();

  late Duration audioDuration;

  String audioName = '';

  void resetAudio() {
    audioLoading = false;
    audioLoaded = false;
    notifyListeners();
  }

  void chooseAudio(BuildContext context) async {
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
      audioDuration = (await player.setUrl(result.files.single.path!))!;
      print('audioDuration: $audioDuration');
      print('audioName: $audioName');
    } else {
      showSnackBar(context, 'No file selected.');
    }
    audioLoaded = true;
    notifyListeners();
  }

  showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.blue,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        )
    ));
  }
}