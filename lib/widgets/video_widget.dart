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
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    debugPrint("URL : ${widget.url}");
    controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
  }

  @override
  void dispose(){
    super.dispose();
    controller.dispose();
    debugPrint("disposing video widget");
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: (){
              if(isPlaying){
                controller.pause();
                setState(() {
                  isPlaying = false;
                });
              } else {
                controller.play();
                setState(() {
                  isPlaying = true;
                });
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: VideoPlayer(controller)
                ),
                if(!isPlaying)
                Container(
                  height: 300,
                  width: 300,
                  color: Colors.black.withOpacity(.3),
                  child: const Icon(Icons.play_circle, size: 50, color: Colors.white,),
                )
              ],
            ),
          );
        } else {
          return const Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Center(child: ProgressWidget())
            ),
          );
        }
      },
    );
  }
}