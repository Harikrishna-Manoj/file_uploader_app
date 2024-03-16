import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/domain/service.dart';
import 'package:tem_file_uploader/presentation/widgets.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ScreenUploadFile extends StatelessWidget {
  const ScreenUploadFile({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    File? media;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('mediaurl').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              } else {
                return snapshot.data!.docs.isNotEmpty
                    ? GridView.builder(
                        itemCount: snapshot.data?.docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // number of items in each row
                          mainAxisSpacing: 8.0, // spacing between rows
                          crossAxisSpacing: 8.0, // spacing between columns
                        ),
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          var mediaData = snapshot.data?.docs[index];
                          return mediaData?["videoUrl"] == ""
                              ? SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image.network(
                                      "${mediaData?["imageUrl"]}"))
                              : SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      Image.network(
                                          "${mediaData?["thambNail"]}"),
                                      const Icon(
                                        Icons.video_camera_back_rounded,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ));
                        },
                      )
                    : const Center(
                        child: Text("No uploaded file"),
                      );
              }
            }),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: w * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton.extended(
              label: const Text("Upload Image"),
              onPressed: () async {
                media = await MediaUploadService.mediaPicker(
                    context, MediaType.image);
                if (context.mounted) {
                  media != null
                      ? showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return PreviewWidget(
                              w: w,
                              h: h,
                              media: media,
                              mediaType: MediaType.image,
                            );
                          },
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Select file")));
                }
              },
            ),
            FloatingActionButton.extended(
              label: const Text("Upload Video"),
              onPressed: () async {
                media = await MediaUploadService.mediaPicker(
                    context, MediaType.video);
                if (media != null) {
                  var uint8list = await VideoThumbnail.thumbnailData(
                    video: media!.path,
                    imageFormat: ImageFormat.JPEG,
                    quality: 25,
                  );
                  if (context.mounted) {
                    media != null
                        ? showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return PreviewWidget(
                                thumbnNail: uint8list,
                                w: w,
                                h: h,
                                media: media,
                                mediaType: MediaType.video,
                              );
                            },
                          )
                        : ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Select file")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select file")));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
