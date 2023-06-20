import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/comment.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/comment_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

class PageComments extends StatefulWidget {
  final UserProfile userProfile;
  final int index;
  const PageComments({
    required this.index,
    required this.userProfile,
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
  RecorderController recorderController = RecorderController();      // Initialise
  bool isPlaying = false;
  bool audioRecorded = false;
  DateTime date = DateTime.now();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Post post = context.read<List<Post>>()[widget.index];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Flexible(
              flex: 8,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                                  height: 30,
                                  width: 30,
                                ),
                              )
                              :ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                widget.userProfile.picture!,
                                fit: BoxFit.fill,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userProfile.displayName.capitalize(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if(post.content != null)
                              Text(
                                post.content!
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
                    child: Divider(color: Colors.grey,),
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
                            return CommentLine(
                              comment:Comment.fromFirestore(doc: snapshot.data!)
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
                      onPressed: () {
                        if(isPlaying){
                          recorderController.pause();
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          recorderController.record();
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
                            recorderController.stop();
                            recorderController.reset();
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
                          recorderController: recorderController,
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
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
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
                              String? path = await recorderController.stop();
                              if(path != null){
                                File audioFile = File(path);
                                String pathToUpload = "${context.read<UserProfile>().email}_audio_recorded_${date.day}${date.minute}${date.year}${date.minute}${date.second}";
                                String downloadUrl = await Util.uploadFileToFirebaseStorage(pathToUpload, audioFile);
                                await post.addComment(
                                  Comment(
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
                                });
                                scrollController.jumpTo(scrollController.position.maxScrollExtent*2);
                              }
                            } else {
                              if(textController.text.isNotEmpty){
                                await post.addComment(
                                  Comment(
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
                              setState(() {
                                showMicrowave = true;
                                isPlaying = true;
                                audioRecorded = true;
                              });
                              await recorderController.record();
                            },
                            onLongPressEnd: (details) async {
                              await recorderController.pause();
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