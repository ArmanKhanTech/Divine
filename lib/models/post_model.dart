import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? postId;
  String? ownerId;
  String? username;
  String? location;
  String? description;
  String? mediaUrl;

  List<String>? mentions = [];
  List<String>? hashtags = [];

  Timestamp? timestamp;

  Likes? likes;

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
    this.likes,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username= json['username'];
    description = json['description'];
    mediaUrl = json['mediaUrl'];
    timestamp = json['timestamp'];
    mentions = json['tags'].cast<String>();
    hashtags = json['hashtags'].cast<String>();
    likes = Likes.fromJson(json['likes']);
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
    data['tags'] = mentions;
    data['hashtags'] = hashtags;
    data['likes'] = likes?.toJson();

    return data;
  }
}

class Likes {
  int? count = 0;
  List<String>? userIds = [];

  Likes({
    this.count, this.userIds});

  Likes.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    userIds = json['userIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['userIds'] = userIds;

    return data;
  }
}