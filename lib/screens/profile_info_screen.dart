import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ProfileInfoScreen extends StatefulWidget{
  final String? country, email;
  final Timestamp? timeStamp;

  const ProfileInfoScreen({super.key, this.country, this.email, required this.timeStamp});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen>{
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}