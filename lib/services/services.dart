import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import '../utilities/file_utility.dart';
import '../utilities/firebase.dart';

abstract class Service {
  Future<String> uploadImage(Reference ref, File file) async {
    String ext = FileUtility.getFileExtension(file);
    Reference storageReference = ref.child("${uuid.v4()}.$ext");
    UploadTask uploadTask = storageReference.putFile(file);

    await uploadTask.whenComplete(() => null);

    String fileUrl = await storageReference.getDownloadURL();

    return fileUrl;
  }
}
