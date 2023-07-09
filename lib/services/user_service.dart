import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/services.dart';
import '../../utilities/firebase.dart';

class UserService extends Service {
  // Get current user's ID.
  String currentUid() {
    return auth.currentUser!.uid;
  }

  // Update last seen in DMs after closing and opening the app.
  setUserStatus(bool isUserOnline) {
    var user = auth.currentUser;
    if (user != null) {
      usersRef.doc(user.uid).update({'isOnline': isUserOnline, 'lastSeen': Timestamp.now()});
    }
  }

  // Display the profile pic in ProfileScreen after update.
  updateProfile({File? image, String? username, String? bio, String? country, String? link, String? profession}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    users.username = username;
    users.bio = bio;
    users.country = country;
    users.url = link;
    users.profession = profession;
    if (image != null) {
      users.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'username': username,
      'bio': bio,
      'country': country,
      'photoUrl': users.photoUrl ?? '',
      'link': link,
      'profession': profession,
    });
    return true;
  }
}
