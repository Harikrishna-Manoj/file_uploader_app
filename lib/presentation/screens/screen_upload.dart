import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tem_file_uploader/core/constant.dart';
import 'package:tem_file_uploader/domain/service.dart';
import 'package:tem_file_uploader/main.dart';
import 'package:tem_file_uploader/presentation/screens/screen_video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ScreenUploadFile extends StatefulWidget {
  const ScreenUploadFile({super.key});

  @override
  State<ScreenUploadFile> createState() => _ScreenUploadFileState();
}

class _ScreenUploadFileState extends State<ScreenUploadFile> {
  File? media;
  UploadTask? uploadTask;
  Future<String> uploadMedia(File mediaFile, MediaType mediaType,
      [Uint8List? thumbNail]) async {
    final referenceRoot = FirebaseStorage.instance.ref();
    final referenceDirMedia = referenceRoot.child('media');
    final referenceMediaToupload = referenceDirMedia
        .child(DateTime.now().millisecondsSinceEpoch.toString());
    String? mediaDownloaddUrl;
    String? thumbNailDownloaddUrl;
    setState(() {
      uploadTask = referenceMediaToupload.putFile(mediaFile);
    });
    try {
      final snapShot = await uploadTask?.whenComplete(() {});
      mediaDownloaddUrl = await snapShot?.ref.getDownloadURL();

      log(mediaDownloaddUrl ?? '');
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
        setState(() {
          uploadTask = null;
        });
        setState(() {
          uploadTask = null;
        });
      }

      log(mediaDownloaddUrl ?? '');
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

    return mediaDownloaddUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Your Favourite Moments"),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('mediaurl')
                    .snapshots(),
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
                                  ? InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                child: Image.network(
                                                  "${mediaData?["imageUrl"]}",
                                                ),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: IconButton(
                                                    onPressed: () =>
                                                        navigatorKey
                                                            .currentState
                                                            ?.pop(),
                                                    icon: const Icon(
                                                      Icons
                                                          .highlight_remove_sharp,
                                                      color: Colors.white,
                                                      size: 30,
                                                    )),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Image.network(
                                            "${mediaData?["imageUrl"]}",
                                            fit: BoxFit.fill,
                                          )),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                child: ScreenVideoPlayer(
                                                    videoUrl:
                                                        mediaData?["videoUrl"]),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: IconButton(
                                                    onPressed: () =>
                                                        navigatorKey
                                                            .currentState
                                                            ?.pop(),
                                                    icon: const Icon(
                                                      Icons
                                                          .highlight_remove_sharp,
                                                      color: Colors.white,
                                                      size: 30,
                                                    )),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Image.network(
                                                "${mediaData?["thambNail"]}",
                                                fit: BoxFit.cover,
                                              ),
                                              const Icon(
                                                Icons
                                                    .play_circle_outline_outlined,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            ],
                                          )),
                                    );
                            },
                          )
                        : const Center(
                            child: Text("No uploaded files"),
                          );
                  }
                }),
          ],
        ),
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
                  if (media != null) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
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
                                child: Image.file(
                                  media!,
                                  fit: BoxFit.contain,
                                ),
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
                                      child: const Text("Cancel",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                  TextButton(
                                      onPressed: () async {
                                        if (media != null) {
                                          uploadMedia(
                                            media!,
                                            MediaType.image,
                                          );
                                        }
                                        navigatorKey.currentState?.pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                content:
                                                    StreamBuilder<TaskSnapshot>(
                                                        stream: uploadTask
                                                            ?.snapshotEvents,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            final data =
                                                                snapshot.data!;
                                                            double progress =
                                                                (data.bytesTransferred /
                                                                        data.totalBytes) *
                                                                    100;
                                                            return SizedBox(
                                                              width: w * 0.4,
                                                              height: h * 0.25,
                                                              child: Center(
                                                                  child:
                                                                      CircularPercentIndicator(
                                                                header: data.bytesTransferred ==
                                                                        data.totalBytes
                                                                    ? const Text(
                                                                        "Uploaded",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 20),
                                                                      )
                                                                    : const Text(
                                                                        "Uploading...",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 20),
                                                                      ),
                                                                footer: data.bytesTransferred ==
                                                                        data.totalBytes
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                20),
                                                                        child:
                                                                            InkWell(
                                                                          onTap: () => navigatorKey
                                                                              .currentState
                                                                              ?.pop(),
                                                                          child:
                                                                              const Text(
                                                                            "Ok",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: 20),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 20.0),
                                                                        child:
                                                                            Text(
                                                                          "Ok",
                                                                          style: TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                animation: true,
                                                                animateFromLastPercent:
                                                                    true,
                                                                radius: 50,
                                                                progressColor:
                                                                    Colors
                                                                        .purple,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                percent:
                                                                    progress /
                                                                        100,
                                                                center: Text(
                                                                  progress
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              )),
                                                            );
                                                          } else {
                                                            return const SizedBox();
                                                          }
                                                        }));
                                          },
                                        );
                                      },
                                      child: const Text("Upload",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)))
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Select file")));
                  }
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
                                      child: Image.memory(uint8list!),
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
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        TextButton(
                                            onPressed: () async {
                                              if (media != null) {
                                                uploadMedia(media!,
                                                    MediaType.video, uint8list);
                                              }
                                              navigatorKey.currentState?.pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      content: StreamBuilder<
                                                              TaskSnapshot>(
                                                          stream: uploadTask
                                                              ?.snapshotEvents,
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              final data =
                                                                  snapshot
                                                                      .data!;
                                                              double progress =
                                                                  (data.bytesTransferred /
                                                                          data.totalBytes) *
                                                                      100;
                                                              return SizedBox(
                                                                width: w * 0.4,
                                                                height:
                                                                    h * 0.25,
                                                                child: Center(
                                                                    child:
                                                                        CircularPercentIndicator(
                                                                  header: data.bytesTransferred ==
                                                                          data.totalBytes
                                                                      ? const Text(
                                                                          "Uploaded",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 20),
                                                                        )
                                                                      : const Text(
                                                                          "Uploading...",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 20),
                                                                        ),
                                                                  footer: data.bytesTransferred ==
                                                                          data.totalBytes
                                                                      ? Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 20),
                                                                          child:
                                                                              InkWell(
                                                                            onTap: () =>
                                                                                navigatorKey.currentState?.pop(),
                                                                            child:
                                                                                const Text(
                                                                              "Ok",
                                                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(top: 20.0),
                                                                          child:
                                                                              Text(
                                                                            "Ok",
                                                                            style:
                                                                                TextStyle(color: Colors.grey, fontSize: 20),
                                                                          ),
                                                                        ),
                                                                  animation:
                                                                      true,
                                                                  animateFromLastPercent:
                                                                      true,
                                                                  radius: 50,
                                                                  progressColor:
                                                                      Colors
                                                                          .purple,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  percent:
                                                                      progress /
                                                                          100,
                                                                  center: Text(
                                                                    progress
                                                                        .toStringAsFixed(
                                                                            1),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )),
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          }));
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Upload",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
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
