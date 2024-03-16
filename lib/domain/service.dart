import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/presentation/widgets.dart';
// import 'package:permission_handler/permission_handler.dart';

class MediaUploadService {
  static Future mediaPicker(BuildContext context, MediaType media) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => const PermissionSettingDialog(),
        );
      }
    } else {
      try {
        final mediaPicker = ImagePicker();
        XFile? file = media == MediaType.image
            ? await mediaPicker.pickImage(source: ImageSource.gallery)
            : await mediaPicker.pickVideo(source: ImageSource.gallery);
        if (file == null) {
          return;
        }
        File mediaFile = File(file.path);
        int length = await mediaFile.length();
        if (length <= 10000000) {
          return mediaFile;
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("File should be maximum 10 MB")));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Something went wrong")));
        }
      }
    }
  }

  static Future<String> uploadImage(File mediaFile) async {
    final referenceRoot = FirebaseStorage.instance.ref();
    final referenceDirImage = referenceRoot.child('media');
    final referenceImageToupload = referenceDirImage
        .child(DateTime.now().millisecondsSinceEpoch.toString());
    String? downloadedUrl;
    try {
      final uploadRef = await referenceImageToupload.putFile(mediaFile);
      downloadedUrl = await referenceImageToupload.getDownloadURL();
    } catch (e) {
      return e.toString();
    }
    String meidaName = path.basename(mediaFile.path);
    String fileExtension = path.extension(meidaName);

    log(fileExtension);
    log(downloadedUrl);
    final FirebaseFirestore ref = FirebaseFirestore.instance;
    final dataBaseRef = ref.collection("mediaurl").doc();
    dataBaseRef.set({"mediaUrl": downloadedUrl});
    return downloadedUrl;
  }

  static Stream getData() async* {
    final FirebaseFirestore ref = FirebaseFirestore.instance;
    final dataBaseRef = ref.collection("mediaurl");
    final mediaData = await dataBaseRef.get();
    yield mediaData.docs.toList();
  }
}
