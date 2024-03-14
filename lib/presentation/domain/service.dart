import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaUploadService {
  static filepicker() async {
    final imagePickedData = ImagePicker();
    XFile? file = await imagePickedData.pickMedia();
    if (file == null) {
      return;
    }
    File imagefile = File(file.path);
    log(imagefile.toString());
    int length = await imagefile.length();
    log(length.toString());
  }
}
