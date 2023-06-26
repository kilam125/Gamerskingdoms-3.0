import 'package:flutter/material.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:just_audio/just_audio.dart';

class AudioWidget extends StatefulWidget {
  final String url; 
  const AudioWidget({
    super.key,
    required this.url
  });

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  final player = AudioPlayer(); // Create a player
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  DateTime date = DateTime.now();
  late String path;

  @override
  void initState() {
    super.initState();
    initController();
  }


  initController() async {
    debugPrint("Voice note url : ${widget.url}");
    await player.setUrl(widget.url);
    player.setLoopMode(LoopMode.off);
    player.durationStream.listen((durationDuration) {
      debugPrint("Duration changed");
      player.positionStream.listen((positionDuration) async {
        if (durationDuration!.inSeconds == positionDuration.inSeconds) {
          debugPrint("ITS THE END");
          await Future.delayed(const Duration(milliseconds: 500));
          await player.stop();
          await player.seek(Duration.zero);
        }
      });
    });
/*     await controller.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    ); */
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: StreamBuilder(
            stream: player.playingStream,
            builder: (context, snapshot) {
              debugPrint("Snapshot data : ${snapshot.data}");
              if (!snapshot.hasData) {
                return const ProgressWidget();
              }
              bool playing = snapshot.data as bool;
              return IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: playing ? const Icon(
                  Icons.pause,
                    color: Color.fromRGBO(
                      62,
                      62,
                      147,
                      1,
                    ),
                  size: 20
                )
                : const Icon(Icons.play_arrow, color: Color.fromRGBO(62, 62, 147, 1), size: 20),
                onPressed: () async {
                  bool playing = snapshot.data as bool;
                  debugPrint("PLAYER : $playing");
                  if (playing) {
                    setState(() {
                      player.pause();
                    });
                  } else {
                    setState(() {
                      player.play();
                    });
                  }
                }
              );
              }
            )
          ),
        Flexible(
          flex: 14,
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Column(
              children: [
                StreamBuilder(
                    stream: player.durationStream,
                    builder: (context, snapshotDt) {
                      if (!snapshotDt.hasData) {
                        return const ProgressWidget();
                      }
                      Duration dt = snapshotDt.data as Duration;
                      return StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, snapshotPos) {
                            if (!snapshotPos.hasData) {
                              return const ProgressWidget();
                            }
                            Duration ps = snapshotPos.data as Duration;
                            if (ps.inSeconds == dt.inSeconds) {
                              debugPrint("END");
                            }
                            return Slider(
                              min: 0,
                              max: dt.inSeconds.toDouble(),
                              value: ps.inSeconds.toDouble(),
                              activeColor: const Color.fromARGB(255, 242, 24, 46),
                              inactiveColor: const Color.fromARGB(255, 167, 69, 69),
                              onChanged: (value) async {
                                //player.setClip(start:Duration(seconds: value.toInt()), end: Duration(seconds: dt.inSeconds.toInt()));
                              },
                            );
                          });
                    }),
              ],
            )
          ),
        ),
        const Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Icon(Icons.audio_file),
        )
      ],
    );
  }
}