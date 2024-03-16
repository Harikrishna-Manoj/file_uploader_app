import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScreenVideoPlayer extends StatefulWidget {
  const ScreenVideoPlayer({super.key, required this.videoUrl});
  final String videoUrl;
  @override
  State<ScreenVideoPlayer> createState() => _ScreenVideoPlayerState();
}

class _ScreenVideoPlayerState extends State<ScreenVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  late Future<void> initialVideoPlayerFuture;
  @override
  void initState() {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    initialVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      videoPlayerController.play();
      videoPlayerController.setLooping(true);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: videoPlayerController.value.aspectRatio,
            child: VideoPlayer(videoPlayerController),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
      },
    );
  }
}
