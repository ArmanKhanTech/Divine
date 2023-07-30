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

  Timestamp? signedUpAt;
  Timestamp? lastSeen;

  UserHashtags? userHashtags;

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
        this.userHashtags});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['name'];
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
    userHashtags = UserHashtags.fromJson(json['hashtags']);
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = username;
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
    data['hashtags'] = userHashtags?.toJson();
    data['gender'] = gender;

    return data;
  }
}

class UserHashtags {
  String? tag = '';
  int? count = 0;

  UserHashtags({
    this.tag,
    this.count});

  UserHashtags.fromJson(Map<String, dynamic> json) {
    tag = json['tag'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tag'] = tag;
    data['count'] = count;
    return data;
  }
}