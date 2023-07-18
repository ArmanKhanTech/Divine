import 'package:cloud_firestore/cloud_firestore.dart';

// Convert firebase JSON response to a Dart object & vice versa & save to SharedPreference.
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

  Timestamp? signedUpAt;
  Timestamp? lastSeen;

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
        this.isVerified});

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

    return data;
  }
}