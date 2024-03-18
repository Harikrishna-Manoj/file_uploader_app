import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/presentation/screens/widgets.dart';
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
}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({
    super.key,
    required this.stream,
  });
  final Stream<TaskSnapshot> stream;

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          double progress = data!.bytesTransferred / data.totalBytes;
          return SizedBox(
            width: double.infinity,
            height: 20,
            child: CircularPercentIndicator(
              radius: 100,
              percent: (progress / 100),
              progressColor: Colors.purple,
            ),
          );
        } else {
          return const Center(
            child: Text("Error"),
          );
        }
      },
    );
  }
}
