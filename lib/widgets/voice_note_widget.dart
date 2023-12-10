import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:just_audio/just_audio.dart';

class VoiceNoteWidget extends StatefulWidget {
  final String url; 
  const VoiceNoteWidget({
    super.key,
    required this.url
  });

  @override
  State<VoiceNoteWidget> createState() => _VoiceNoteWidgetState();
}

class _VoiceNoteWidgetState extends State<VoiceNoteWidget> {
  final player = AudioPlayer();
  //final adPlayer = ad.AudioPlayer(playerId: "test"); // Create a player
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  DateTime date = DateTime.now();
  late String path;

  @override
  void initState() {
    super.initState();
    player.positionStream.listen((positionDuration) async {
      var totalDuration = player.duration;
      if (totalDuration != null && positionDuration >= totalDuration) {
        await player.seek(Duration.zero);
        await player.pause();
        // Optionally, if you want to automatically play again, uncomment the next line
        // await player.play();
      }
    });
  }

  Future<bool> initController(String url) async {
    await player.setUrl(url);
    // No need to listen to durationStream here
    return true;
  }

  @override
  void dispose() {
/*     adPlayer.stop();
    adPlayer.dispose(); */
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseStorage.instance.ref(widget.url).getDownloadURL(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return const ProgressWidget();
        }
        return FutureBuilder(
          future: initController(snapshot.data!),
          builder: (context, snp) {
            if(snp.hasError){
              log("snp : ${snp.error.toString()}");
            }
            if(!snp.hasData){
              log("snp data : ${snp.data.toString()}");
              return const ProgressWidget();
            } else {
              return Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: StreamBuilder(
                      stream: player.playingStream,
                      builder: (context, snapshot) {
                        debugPrint("[VOICE NOTE WIDGET] Snapshot data : ${snapshot.data}");
                        if (!snapshot.hasData) {
                          return const ProgressWidget();
                        }
                        //ad.PlayerState playing = snapshot.data!;
                        bool playing = snapshot.data!;
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
                          : const Icon(
                            Icons.play_arrow, 
                            color: Color.fromRGBO(62, 62, 147, 1), 
                            size: 20
                          ),
                          onPressed: () async {
                            bool playing = snapshot.data as bool;
                            debugPrint("PLAYER : $playing");
                            if (playing) {
                              await player.pause();
                            } else {
                              await player.play();
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
                                //stream: adPlayer.onDurationChanged,
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
                                          activeColor: const Color.fromRGBO(62, 62, 147, 1),
                                          inactiveColor: const Color.fromRGBO(143, 148, 204, 1),
                                          onChanged: (value) async {
                                            //player.setClip(start:Duration(seconds: value.toInt()), end: Duration(seconds: dt.inSeconds.toInt()));
                                          },
                                        );
                                      });
                                }),
                          ],
                        )),
                  ),
                  const Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(Icons.mic, size: 30),
                  )
                ],
              );
            }
          }
        );
      }
    );
  }
}