

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

class AddPosts extends StatefulWidget {
  final Function(int) navCallback;
  const AddPosts({
    super.key,
    required this.navCallback
  });

  @override
  State<AddPosts> createState() => _AddPostsState();
}

class _AddPostsState extends State<AddPosts> {
  TextEditingController content = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isAttachmentSend = false;
  bool isLoading = false;

  bool uploadImages = false;
  bool uploadVideo = false;
  bool uploadVoiceNote = false;
  bool uploadAudioFile = false;
  //final record = AudioRecorder();
  final recordController = RecorderController();
  late String fullPath;
  late String localPath;
  DateTime date = DateTime.now();
  late PlayerController controller;
  late File? audioFile;
  List<XFile> listXFileImages = [];
  List<Image> listImages = [];
  XFile? videoFile;
  bool showSendButton = false;

  bool showMicrowave = false;
  bool audioRecorded = false;
  late bool recordPermission;

  bool isPlaying = false;


  Future<String?> convertToMp3(String inputFilePath) async {
    final outputFile = inputFilePath.replaceAll('.aac', '.mp3');
    final command = '-i $inputFilePath -c:a libmp3lame $outputFile';

    try {
      FFmpegSession session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Conversion successful
        return outputFile;
      } else {
        // Handle error, conversion failed
        log("Error in converting file: ${await session.getAllLogsAsString()}");
        return null;
      }
    } catch (e) {
      print("Error during conversion: $e");
      return null;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  initPath() async {
    localPath = await _localPath;
    fullPath = "$localPath/recording_${date.day}_${date.month}_${date.year}_${date.hour}_${date.minute}_${date.second}.aac";
    debugPrint("PATH : $fullPath");
  }

  Future<void> initPermission() async {
    recordPermission = await Util.askMicrophone();
    log("Record permisson : $recordPermission");
  }

  @override
  void initState() {
    super.initState();
    initPermission();
    initPath();
    controller = PlayerController();
  }

  @override
  Widget build(BuildContext context) {
    attachmentTypeByBool(){
      if(uploadImages){
        return 0;
      } else if(uploadVideo){
        return 1;
      } else if(uploadVoiceNote){
        return 2;
      } else {
        return null;
      }
    }
    
    UserProfile user = context.read<UserProfile>();
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.only(right: 40, left: 40, top: MediaQuery.of(context).size.height*.2),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 16, left: 12),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    label: Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Content",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    hintText: "Write your content !"
                  ),
                  controller: content,
                ),
              ),
              Row(
                children: [
                  if(!audioRecorded)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      var result = await picker.pickImage(source: ImageSource.gallery ,imageQuality: 30);
                      if(result != null){
                        setState(() {
                          uploadImages = true;
                          uploadVideo = false;
                          isAttachmentSend = true;
                          listXFileImages = [];
                          listImages = [];
                          listXFileImages.add(result);
                          for (var element in listXFileImages) 
                          {
                            listImages.add(
                              Image.file(
                                File(element.path),
                                height: 100,
                                width: 100,
                              )
                            );
                          }
                        });
                      }
                    }, 
                    icon: const Icon(Icons.image, size: 30,)
                  ),
                  if(!audioRecorded)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      var result = await picker.pickVideo(
                        source: ImageSource.gallery,
                        maxDuration: const Duration(minutes: 1, seconds: 30)
                      );
                      if(result != null){
                        setState(() {
                          isLoading = true;
                        });
                      }
                      var compressResult = await VideoCompress.compressVideo(
                        result!.path,
                        quality:VideoQuality.MediumQuality
                      );
                      if(compressResult != null){
                        setState(() {
                          uploadImages = false;
                          uploadVideo = true;
                          isAttachmentSend = true;
                          isLoading = false;
                          videoFile = XFile(compressResult.path!);
                        });
                      }
                    }, 
                    icon: const Icon(Icons.movie, size: 30,)
                  ),
                  if(!audioRecorded)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                        allowMultiple: false,
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        debugPrint('Selected audio file: ${file.path}');
                        setState(() {
                          audioFile = File(file.path!);
                          uploadAudioFile = true;
                        });
                      }
                    }, 
                    icon: const Icon(
                      Icons.audio_file, 
                      size: 30
                    )
                  ),
                  const Spacer(),
                  GestureDetector(
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
                      if(recordPermission){
                        await recordController.pause();
                        //await recorderController.pause();
                        setState(() {
                          isPlaying = false;
                          showSendButton = true;
                          uploadVoiceNote = true;
                        });
                      }
                    },
                    child: const Icon(Icons.mic, size: 30,)
                  )
                ],
              ),
              if(showMicrowave)
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          await recordController.pause();
                          setState(() {
                            isPlaying = false;
                            uploadVoiceNote = true;
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
                  ),
                  Flexible(
                    flex: 8,
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
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        setState(() {
                          recordController.stop();
                          showMicrowave = false;
                          uploadVoiceNote = false;
                          audioRecorded = false;
                        });
                      },
                    ),
                  )
                ],
              ), 
              if(uploadImages)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...listImages]
              ),
              if((uploadVideo || uploadAudioFile) && !(isLoading))
              const SizedBox(
                height: 100,
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\u2705',
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                    Text(
                      "Attachment choosed",
                      style: TextStyle(
                        color: Colors.black
                      ),
                    )
                  ],
                ),
              ),
              isLoading ?
              const ProgressWidget()
              :Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if(uploadImages){
                      List<String> downloadUrls = [];
                      Uint8List filesAsBytes = await listXFileImages.first.readAsBytes();
                      List<Uint8List> result = [filesAsBytes];
                      for(Uint8List elem in result){
                        if(!mounted)return;
                        final TaskSnapshot upload = await FirebaseStorage.instance.ref(user.email).child(listXFileImages.first.name+DateTime.now().toString()).putData(elem, SettableMetadata(contentType: 'image/jpeg'));
                        final String downloadUrl = await upload.ref.getDownloadURL();
                        downloadUrls.add(downloadUrl);
                      }
                      debugPrint(downloadUrls.toString());
                      await FirebaseFirestore.instance.collection("posts").add({
                        "visible":true,
                        "userName":user.displayName,
                        "attachmentType":attachmentTypeByBool(),
                        "attachmentUrl":downloadUrls.first,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                        "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                      });
                      debugPrint("Done");
                    } else if(uploadVideo){
                      List<String> downloadUrls = [];
                      Uint8List filesAsBytes = await videoFile!.readAsBytes();
                      List<Uint8List> result = [filesAsBytes];
                      for(Uint8List elem in result){
                        if(!mounted)return;
                        final TaskSnapshot upload = await FirebaseStorage.instance.ref(user.email).child(videoFile!.name+date.day.toString()+date.minute.toString()+date.year.toString()+date.minute.toString()+date.second.toString()).putData(elem, SettableMetadata(contentType: 'video/mp4'));
                        final String downloadUrl = await upload.ref.getDownloadURL();
                        downloadUrls.add(downloadUrl);
                      }
                      debugPrint(downloadUrls.toString());
                      await FirebaseFirestore.instance.collection("posts").add({
                        "visible":true,
                        "userName":user.displayName,
                        "attachmentType":attachmentTypeByBool(),
                        "attachmentUrl":downloadUrls.first,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                        "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                      });
                      debugPrint("Done");
                    } else if(uploadVoiceNote){
                      debugPrint("upload voice note");
                      String? file = await recordController.stop();
                      String? result = await convertToMp3(file!);
                      if(result!=null){
                        log(result);
                        Uint8List filesAsBytes = await File(result!).readAsBytes();
                        if(!mounted)return;
                        final TaskSnapshot upload = await FirebaseStorage.instance
                          .ref("${user.email}_audio_recorded_${date.day}${date.minute}${date.year}${date.minute}${date.second}.mp3")
                          .putData(
                            filesAsBytes, 
                            SettableMetadata(
                              contentType: 'audio/mp3'
                            )
                          );
                        log("Data upload done");
                        await FirebaseFirestore.instance.collection("posts").add({
                          "visible":true,
                          "userName":user.displayName,
                          "attachmentType":2,
                          "attachmentUrl":upload.ref.fullPath,
                          "comments":[],
                          "content":content.text,
                          "datePost":DateTime.now(),
                          "likers":[],
                          "likes":0,
                          "owner":user.userRef,
                          "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                        });
                        debugPrint("Posted");
                        debugPrint("Done");
                      }
                    } else if(uploadAudioFile){
                      debugPrint("upload voice note");
                      if(audioFile!=null){
                        Uint8List filesAsBytes = await (audioFile)!.readAsBytes();
                        if(!mounted)return;
                        final TaskSnapshot upload = await FirebaseStorage.instance
                          .ref("${user.email}_audio_recorded_${date.day}${date.minute}${date.year}${date.minute}${date.second}")
                          .putData(
                            filesAsBytes, 
                            SettableMetadata(contentType: 'audio/mp3')
                          );
                        final String downloadUrl = await upload.ref.getDownloadURL();
                        await FirebaseFirestore.instance.collection("posts").add({
                          "visible":true,
                          "userName":user.displayName,
                          "attachmentType":3,
                          "attachmentUrl":downloadUrl,
                          "comments":[],
                          "content":content.text,
                          "datePost":DateTime.now(),
                          "likers":[],
                          "likes":0,
                          "owner":user.userRef,
                          "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                        });
                        debugPrint("Done");
                    } else {
                      await FirebaseFirestore.instance.collection("posts").add({
                        "visible":true,
                        "userName":user.displayName,
                        "attachmentType":null,
                        "attachmentUrl":null,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                        "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                      });
                    }
                    } else {
                      if(content.text.isEmpty){
                        await PopUp.okPopUp(
                          context: context, 
                          title: "Wait", 
                          message: "You can't post an empty message"
                        );
                      } else {
                        await FirebaseFirestore.instance.collection("posts").add({
                          "visible":true,
                          "userName":user.displayName,
                          "attachmentType":null,
                          "attachmentUrl":null,
                          "comments":[],
                          "content":content.text,
                          "datePost":DateTime.now(),
                          "likers":[],
                          "likes":0,
                          "owner":user.userRef,
                          "skills":user.skills.map((e) => Util.skillsToString(e)).toList()
                        });
                        debugPrint("Done");
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                    if((uploadImages || uploadVideo || uploadVoiceNote || uploadAudioFile || content.text.isNotEmpty)){
                      if(!mounted)return;
                      await PopUp.okPopUp(
                        context: context, 
                        title: "Done", 
                        message: "You've posted successfully"
                      );
                      widget.navCallback(0);
                    }
                  },
                  child: const Text("Post")
                ),
              ),
              const SizedBox(height: 40),
              const Text("Max video lenght : 30 seconds")
            ],
          ),
        ),
      ),
    );
  }
}