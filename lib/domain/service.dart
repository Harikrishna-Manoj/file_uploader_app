import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  static Future<String> uploadMedia(File mediaFile, MediaType mediaType,
      [Uint8List? thumbNail]) async {
    final referenceRoot = FirebaseStorage.instance.ref();
    final referenceDirMedia = referenceRoot.child('media');
    final referenceMediaToupload = referenceDirMedia
        .child(DateTime.now().millisecondsSinceEpoch.toString());
    String? mediaDownloaddUrl;
    String? thumbNailDownloaddUrl;

    try {
      await referenceMediaToupload.putFile(mediaFile);
      mediaDownloaddUrl = await referenceMediaToupload.getDownloadURL();
      log(mediaDownloaddUrl);
      if (thumbNail != null) {
        Uint8List imageInUnit8List = thumbNail;
        final tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/image.png').create();
        file.writeAsBytesSync(imageInUnit8List);
        final referenceThumbNailRoot = FirebaseStorage.instance.ref();
        final referenceDirThumbNail =
            referenceThumbNailRoot.child('thumbnails');
        final referenceThumbNailToupload = referenceDirThumbNail
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        await referenceThumbNailToupload.putFile(file);
        thumbNailDownloaddUrl =
            await referenceThumbNailToupload.getDownloadURL();
      }
      log(mediaDownloaddUrl);
      log(thumbNailDownloaddUrl ?? "");
    } catch (e) {
      return e.toString();
    }
    try {
      final FirebaseFirestore ref = FirebaseFirestore.instance;
      final dataBaseRef = ref.collection("mediaurl").doc();
      mediaType == MediaType.image
          ? dataBaseRef.set({"imageUrl": mediaDownloaddUrl, "videoUrl": ""})
          : dataBaseRef.set({
              "videoUrl": mediaDownloaddUrl,
              "thambNail": thumbNailDownloaddUrl,
              "imageUrl": "",
            });
    } catch (e) {
      return e.toString();
    }
    return mediaDownloaddUrl;
  }
}
