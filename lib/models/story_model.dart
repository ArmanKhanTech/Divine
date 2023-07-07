import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  String? url;
  String? statusId;

  List<dynamic>? viewers;
  Timestamp? time;

  StoryModel({
        this.url,
        this.statusId,
        this.time,
        this.viewers});

  StoryModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    statusId = json['statusId'];
    viewers = json['viewers'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusId'] = statusId;
    data['viewers'] = viewers;
    data['url'] = url;
    data['time'] = time;
    return data;
  }
}