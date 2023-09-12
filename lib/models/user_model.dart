import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String? username;
  String? email;
  String? photoUrl;
  String? country;
  String? bio;
  String? id;
  String? link;
  String? type;
  String? profession;
  String? name;
  String? gender;

  int? posts;
  int? mentionsCount;

  List<String>? postsIds;
  List<String>? mentionsIds;

  Timestamp? signedUpAt;
  Timestamp? lastSeen;

  Map<String, dynamic>? userHashtags;

  bool? isOnline;
  bool? isVerified;

  UserModel(
      {this.username,
        this.email,
        this.id,
        this.photoUrl,
        this.signedUpAt,
        this.isOnline,
        this.lastSeen,
        this.bio,
        this.country,
        this.link,
        this.type,
        this.profession,
        this.name,
        this.isVerified,
        this.gender,
        this.userHashtags,
        this.posts,
        this.mentionsCount,
        this.postsIds,
        this.mentionsIds});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    country = json['country'];
    photoUrl = json['photoUrl'];
    signedUpAt = json['createdAt'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    bio = json['bio'];
    id = json['id'];
    link = json['link'];
    type = json['type'];
    profession = json['profession'];
    name = json['name'];
    isVerified = json['isVerified'];
    gender = json['gender'];
    userHashtags = json['hashtags'];
    posts = json['posts'];
    mentionsCount = json['mentionsCount'];
    postsIds = json['postsIds'] != null ? json['postsIds'].cast<String>() : [];
    mentionsIds = json['mentionsIds'] != null ? json['mentionsIds'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['country'] = country;
    data['email'] = email;
    data['photoUrl'] = photoUrl;
    data['bio'] = bio;
    data['createdAt'] = signedUpAt;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['id'] = id;
    data['link'] = link;
    data['type'] = type;
    data['profession'] = profession;
    data['name'] = name;
    data['isVerified'] = isVerified;
    data['hashtags'] = userHashtags;
    data['gender'] = gender;
    data['posts'] = posts;
    data['mentionsCount'] = mentionsCount;
    data['postsIds'] = postsIds;
    data['mentionsIds'] = mentionsIds;

    return data;
  }
}