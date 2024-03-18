import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tem_file_uploader/main.dart';
import 'package:tem_file_uploader/presentation/screens/screen_video_player.dart';

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

class UploadedGridView extends StatelessWidget {
  const UploadedGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('mediaurl').snapshots(),
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
                                            onPressed: () => navigatorKey
                                                .currentState
                                                ?.pop(),
                                            icon: const Icon(
                                              Icons.highlight_remove_sharp,
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
                                            videoUrl: mediaData?["videoUrl"]),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: IconButton(
                                            onPressed: () => navigatorKey
                                                .currentState
                                                ?.pop(),
                                            icon: const Icon(
                                              Icons.highlight_remove_sharp,
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
                                        Icons.play_circle_outline_outlined,
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
        });
  }
}
