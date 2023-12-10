import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart' as ad;

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
  final player = AudioPlayer(); // Create a player
  final adPlayer = ad.AudioPlayer(); // Create a player
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  DateTime date = DateTime.now();
  late String path;

  @override
  void initState() {
    super.initState();
  }


  Future<bool> initController(String url) async {
    await player.setAudioSource(
      AudioSource.uri(Uri.parse(url))
    );
/*     await player.setUrl(
      url,
    ); */
    await player.setLoopMode(LoopMode.off);
    player.durationStream.listen((durationDuration) {
      player.positionStream.listen((positionDuration) async {
        if (durationDuration!.inSeconds == positionDuration.inSeconds) {
          await Future.delayed(const Duration(milliseconds: 500));
          await player.stop();
          await player.seek(Duration.zero);
        }
      });
    });
    return true;
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
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
              log("snp : ${snp.data.toString()}");
              return const ProgressWidget();
            } else {
              log("snp result : ${snp.data!}");
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