import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  String? url;
  String? storyId;

  List<dynamic>? viewers;
  Timestamp? time;

  StoryModel({
        this.url,
        this.storyId,
        this.time,
        this.viewers});

  StoryModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    storyId = json['storyId'];
    viewers = json['viewers'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['storyId'] = storyId;
    data['viewers'] = viewers;
    data['url'] = url;
    data['time'] = time;
    return data;
  }
}