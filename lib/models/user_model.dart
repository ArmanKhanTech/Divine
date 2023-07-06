import 'package:cloud_firestore/cloud_firestore.dart';

// Convert firebase JSON response to a Dart object & vice versa & save to SharedPreference.
class UserModel{
  String? username;
  String? email;
  String? photoUrl;
  String? country;
  String? bio;
  String? id;
  String? url;
  String? type;

  Timestamp? signedUpAt;
  Timestamp? lastSeen;

  bool? isOnline;

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
        this.url,
        this.type});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    country = json['country'];
    photoUrl = json['photoUrl'];
    signedUpAt = json['signedUpAt'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    bio = json['bio'];
    id = json['id'];
    url = json['url'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['country'] = country;
    data['email'] = email;
    data['photoUrl'] = photoUrl;
    data['bio'] = bio;
    data['signedUpAt'] = signedUpAt;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['id'] = id;
    data['url'] = url;
    data['type'] = type;
    return data;
  }
}