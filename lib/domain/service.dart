import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/presentation/widgets.dart';
// import 'package:permission_handler/permission_handler.dart';

class MediaUploadService {
  static mediaPicker(BuildContext context, MediaType media) async {
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
        final imagePickedData = ImagePicker();
        XFile? file = media == MediaType.image
            ? await imagePickedData.pickImage(source: ImageSource.gallery)
            : await imagePickedData.pickVideo(source: ImageSource.gallery);
        if (file == null) {
          return;
        }
        File imagefile = File(file.path);
        log(imagefile.toString());
        int length = await imagefile.length();
        log(length.toString());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }
}
