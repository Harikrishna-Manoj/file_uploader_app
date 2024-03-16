import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/domain/service.dart';
import 'package:tem_file_uploader/main.dart';

class PermissionSettingDialog extends StatelessWidget {
  const PermissionSettingDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
        "Permission Permanently Denied",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
      ),
      actions: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        InkWell(
          onTap: () {
            openAppSettings();
            Navigator.pop(context);
          },
          child: const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class PreviewWidget extends StatelessWidget {
  const PreviewWidget({
    super.key,
    required this.w,
    required this.h,
    required this.media,
    required this.mediaType,
    this.thumbnNail,
  });

  final double w;
  final double h;
  final File? media;
  final MediaType mediaType;
  final Uint8List? thumbnNail;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const Text(
            "Preview",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: w * 0.8,
            height: h * 0.3,
            child: mediaType == MediaType.image
                ? Image.file(
                    media!,
                    fit: BoxFit.contain,
                  )
                : Image.memory(thumbnNail!),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    navigatorKey.currentState?.pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    if (media != null) {
                      mediaType == MediaType.image
                          ? MediaUploadService.uploadMedia(
                              media!, MediaType.image)
                          : MediaUploadService.uploadMedia(
                              media!, MediaType.video, thumbnNail);
                    }
                    navigatorKey.currentState?.pop();
                  },
                  child: const Text("Upload"))
            ],
          )
        ],
      ),
    );
  }
}
