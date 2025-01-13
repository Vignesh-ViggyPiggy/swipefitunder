import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';

class Storage with ChangeNotifier {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  // Future<void> upload(String filename, String filepath, String uid) async {
  //   File file = File(filepath);
  //   print("pic is uploaded");
  //   try {
  //     storage.ref().child('pics/$uid/$filename').putFile(file);
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> upload(String filename, String filepath, String uid) async {
    File file = File(filepath);
    print("Uploading pic...");
    try {
      // Create a reference to the location in Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('pics/$uid/$filename');

      // Upload the file with the content type set to 'image/jpeg'
      await ref.putFile(
        file,
        firebase_storage.SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      print("Upload successful!");
    } on Exception catch (e) {
      print("Error uploading file: $e");
    }
  }

  Future<String?> upload_and_download(String filepath, String uid) async {
    try {
      // Step 1: Upload the file
      await upload("temp", filepath, uid);

      // Step 2: Delay for processing time (if necessary)
      await Future.delayed(const Duration(seconds: 3));

      // Step 3: Get the download URL
      String fileUrl =
          await storage.ref().child('pics/$uid/temp').getDownloadURL();
      return fileUrl;
    } catch (e) {
      print("Error in upload_and_download: $e");
      return null;
    }
  }

  Future<void> delete(String filename) async {
    // File file = File(filepath);
    print("pic is uploaded");
    try {
      storage.ref().child('pics/$filename').delete();
    } on Exception catch (e) {
      print(e);
    }
  }

  List<String> list = [];
}
