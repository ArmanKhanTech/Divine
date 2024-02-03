import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? postId;
  String? ownerId;
  String? username;
  String? location;
  String? description;
  String? mediaType;

  List<dynamic>? mediaUrl = [];
  List<dynamic>? mentions = [];
  List<dynamic>? hashtags = [];

  Timestamp? timestamp;

  PostModel({
    this.id,
    this.postId,
    this.ownerId,
    this.location,
    this.description,
    this.mediaUrl,
    this.username,
    this.timestamp,
    this.mentions,
    this.hashtags,
    this.mediaType,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username= json['username'];
    description = json['description'];
    mediaUrl = json['mediaUrl'].cast<String>();
    timestamp = json['timestamp'];
    mediaType = json['type'];
    if (json['mentions'] != null) {
      mentions = json['mentions'].cast<String>();
    } else {
      mentions = [];
    }
    if (json['hashtags'] != null) {
      hashtags = json['hashtags'].cast<String>();
    } else {
      hashtags = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['postId'] = postId;
    data['ownerId'] = ownerId;
    data['location'] = location;
    data['description'] = description;
    data['mediaUrl'] = mediaUrl;
    data['timestamp'] = timestamp;
    data['username'] = username;
    data['mentions'] = mentions;
    data['hashtags'] = hashtags;
    data['type'] = mediaType;

    return data;
  }
}
