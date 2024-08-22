import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/comment.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/comment_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PageComments extends StatefulWidget {
  final UserProfile userProfile;
  final DocumentReference postRef;
  const PageComments({
    required this.userProfile,
    required this.postRef,
    super.key
  });
  static String routeName = "/PageComments";
  @override
  State<PageComments> createState() => _PageCommentsState();
}

class _PageCommentsState extends State<PageComments> {
  final formKey = GlobalKey<FormState>();
  int activeIndex = 0;
  TextEditingController textController = TextEditingController();
  String message = "";
  bool showSendButton = false;
  bool showMicrowave = false;
  late PlayerController controller;
  bool isPlaying = false;
  bool audioRecorded = false;
  late bool recordPermission;
  DateTime date = DateTime.now();
  final scrollController = ScrollController();
  final recordController = RecorderController();
  late String fullPath;
  late String localPath;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> initPermission() async {
    recordPermission = await Util.askMicrophone();
    log("Record permisson : $recordPermission");
  }

  initPath() async {
    localPath = await _localPath;
    fullPath = "$localPath/recording_${date.day}_${date.month}_${date.year}_${date.hour}_${date.minute}_${date.second}.aac";
    debugPrint("PATH : $fullPath");
  }

  @override
  void initState() {
    super.initState();
    initPermission();
    initPath();
  }
  
  @override
  Widget build(BuildContext context) {
    Post post = context.read<List<Post>>().firstWhere((post) => (post.postRef == widget.postRef));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            if(kDebugMode)
            Text("Je suis : ${context.read<UserProfile>().displayName}"),
            if(kDebugMode)
            Text("Post owner : ${widget.userProfile.displayName}"),
            Flexible(
              flex: 8,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.only(left: 16.0, right: 8, top: 16, bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle
                            ),
                            child: widget.userProfile.picture == null ?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  "assets/images/userpic.png", 
                                  fit: BoxFit.fill,
                                  height: 50,
                                  width: 50,
                                ),
                              )
                              :ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                widget.userProfile.picture!,
                                fit: BoxFit.fill,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 6,
                          child: Column(
                            children: [
                              Text(
                                widget.userProfile.displayName.capitalize(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if(post.content != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  post.content!
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Container(color: Colors.green)
                        )
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(color: Color.fromARGB(255, 46, 46, 46),),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      List.generate(
                        post.comments.length, 
                        (index) => StreamBuilder(
                          stream: (post.comments[index] as DocumentReference).snapshots(),
                          builder: (context, snapshot) {
                            if(!snapshot.hasData){
                              return const ProgressWidget();
                            }
                            Comment comment = Comment.fromFirestore(doc: snapshot.data!);
                            return StreamBuilder(
                              stream: post.owner.get().asStream(),
                              builder: (context, postOwner) {
                                if(!postOwner.hasData){
                                  return const ProgressWidget();
                                }
                                return CommentLine(
                                  myself: context.read<UserProfile>(),
                                  comment: comment,
                                  nested: true,
                                  postOwner: postOwner.data,
                                );
                              }
                            );
                          }
                        )
                      )
                    )
                  ),
                ],
              ),
            ),
            Flexible(
              child:Container(
                color: const Color.fromRGBO(249, 249, 249, 1),
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 4.0, right: 4.0, top: 8.0),
                  child: Row(children: <Widget>[
                    if(showMicrowave)
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isPlaying ? 
                        Icons.pause_circle : Icons.play_circle,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        if(isPlaying){
                          recordController.pause();
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          await recordController.record(
                            bitRate: 96000,
                            sampleRate: 48000,
                            androidEncoder: AndroidEncoder.aac,
                            iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
                            path: fullPath
                          );
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                    ),
                    if(showMicrowave)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            recordController.stop();
                            recordController.reset();
                            audioRecorded = false;
                            isPlaying = false;
                            showMicrowave = false;
                            showSendButton = false;
                          });
                        },
                      ),
                    ),
                    showMicrowave ?
                      Expanded(
                        child: AudioWaveforms(
                          size: Size(MediaQuery.of(context).size.width, 10.0),
                          recorderController: recordController,
                          enableGesture: true,
                          waveStyle: const WaveStyle(
                            middleLineColor: Colors.transparent,
                            waveColor: Color.fromRGBO(62, 62, 147, 1),
                            showDurationLabel: false,
                            spacing: 5.0,
                            showBottom: true,
                            extendWaveform: true,
                            showMiddleLine: true,
                          ),
                        ),
                      ):
                    Expanded(
                      child:RawScrollbar(
                        controller: scrollController,
                        minOverscrollLength: 15,
                        thumbVisibility: true,
                        mainAxisMargin: 5,
                        crossAxisMargin: 10,
                        child: TextFormField(
                          scrollController: scrollController,
                          minLines: 1,
                          maxLines: 7,
                          keyboardType: TextInputType.multiline,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          controller: textController,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          enableSuggestions: true,
                          style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 20),
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 240, 244, 255),
                            hintText: "Message...",
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0, color: Colors.transparent),
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0, color: Colors.black),
                              gapPadding: 10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0, color: Colors.red),
                              gapPadding: 1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            if (textController.text.isNotEmpty) {
                              setState(() {
                                showSendButton = true;
                              });
                            } else {
                              setState(() {
                                showSendButton = false;
                              });
                            }
                          }),
                          onEditingComplete: () async {},
                        ),
                      ),
                    ),
                    ((showSendButton && textController.text.isNotEmpty) || (showSendButton && audioRecorded))
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () async {
                            if(audioRecorded){
                              String? path = await recordController.stop();
                              if(path != null){
                                String? result = await Util.convertToMp3(path);
                                // ignore: use_build_context_synchronously
                                Uint8List filesAsBytes = await File(result!).readAsBytes();
                                if(!mounted)return;
                                final TaskSnapshot upload = await FirebaseStorage.instance
                                  .ref("${context.read<UserProfile>().email}_audio_recorded_${date.day}${date.minute}${date.year}${date.minute}${date.second}.mp3")
                                  .putData(
                                    filesAsBytes, 
                                    SettableMetadata(
                                      contentType: 'audio/mp3'
                                    )
                                  );
                                log("Data upload done");
                                String downloadUrl = upload.ref.fullPath;
                                await post.addComment(
                                  Comment(
                                    ref: FirebaseFirestore.instance.collection("comments").doc(),
                                    commentator: context.read<UserProfile>().userRef, 
                                    post: post.postRef, 
                                    attachmentPresent: false, 
                                    date: DateTime.now(),
                                    content: textController.text,
                                    attachmentUrl: downloadUrl,
                                    attachmentType: AttachmentType.voice
                                  )
                                );
                                textController.clear();
                                setState(() {
                                  showMicrowave = false;
                                  audioRecorded = false;
                                });
                                scrollController.jumpTo(scrollController.position.maxScrollExtent*2);
                              }
                            } else {
                              if(textController.text.isNotEmpty){
                                await post.addComment(
                                  Comment(
                                    ref: FirebaseFirestore.instance.collection("comments").doc(),
                                    commentator: context.read<UserProfile>().userRef, 
                                    post: post.postRef, 
                                    attachmentPresent: false, 
                                    date: DateTime.now(),
                                    content: textController.text,
                                    attachmentUrl: null,
                                    attachmentType: null
                                  )
                                );
                                textController.clear();
                                setState(() {});
                                scrollController.jumpTo(scrollController.position.maxScrollExtent*2);
                              }
                            }
                          },
                        )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: GestureDetector(
                          onLongPress: () async {
                            FocusScope.of(context).unfocus();
                            if(recordPermission){
                              setState(() {
                                showMicrowave = true;
                                isPlaying = true;
                                audioRecorded = true;
                              });
                              await recordController.record(
                                bitRate: 96000,
                                sampleRate: 48000,
                                androidEncoder: AndroidEncoder.aac,
                                iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
                                path: fullPath
                              );
                            } else {
                              PopUp.okPopUp(
                                context: context, 
                                title: "Wait...", 
                                message: "Please give the permission to Gamers Kindgom to use the microphone so you can use voice note.",
                                okCallBack: () {
                                  Util.askMicrophoneOrOpenSettings();
                                }
                              );
                            }
                          },
                          onLongPressEnd: (details) async {
                            await recordController.pause();
                            setState(() {
                              isPlaying = false;
                              showSendButton = true;
                              audioRecorded = true;
                            });
                          },
                          child: const Icon(
                            Icons.mic_rounded,
                            size: 30,
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}