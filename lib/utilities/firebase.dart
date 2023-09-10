import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth auth = FirebaseAuth.instance;

FirebaseFirestore firestore = FirebaseFirestore.instance;

FirebaseStorage storage = FirebaseStorage.instance;

const Uuid uuid = Uuid();

CollectionReference usersRef = firestore.collection('users');
CollectionReference chatRef = firestore.collection("chats");
CollectionReference postRef = firestore.collection('posts');
CollectionReference commentRef = firestore.collection('comments');
CollectionReference notificationRef = firestore.collection('notifications');
CollectionReference followersRef = firestore.collection('followers');
CollectionReference followingRef = firestore.collection('following');
CollectionReference likesRef = firestore.collection('likes');
CollectionReference chatIdRef = firestore.collection('chatIds');
CollectionReference storyRef = firestore.collection('stories');
CollectionReference hashTagsRef = firestore.collection('hashTags');
CollectionReference savedRef = firestore.collection('savedPosts');

Reference profilePic = storage.ref().child('profilePic');
Reference posts = storage.ref().child('posts');
Reference stories = storage.ref().child('stories');