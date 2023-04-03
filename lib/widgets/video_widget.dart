import 'package:flutter/material.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  const VideoWidget({
    super.key,
    required this.url
  });
  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    debugPrint("URL : ${widget.url}");
    controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: (){
              controller.play();
            },
            child: SizedBox(
              height: 300,
              width: 300,
              child: VideoPlayer(controller)
            ),
          );
        } else {
          return const Center(
            child: ProgressWidget(),
          );
        }
      },
    );
  }
}