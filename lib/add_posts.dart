

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:image_picker/image_picker.dart';
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

  DateTime now = DateTime.now();

  List<XFile> listXFileImages = [];
  List<Image> listImages = [];
  XFile? videoFile;
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
                      child: Text("Content"),
                    ),
                    hintText: "Write your content !"
                  ),
                  controller: content,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      var result = await picker.pickImage(source: ImageSource.gallery ,imageQuality: 30);
                      if(result != null){
                        setState(() {
                          uploadImages = true;
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
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      var result = await picker.pickVideo(source: ImageSource.gallery);
                      var compressResult = await VideoCompress.compressVideo(
                        result!.path,
                        quality:VideoQuality.LowQuality
                      );
                      if(compressResult != null){
                        setState(() {
                          uploadVideo = true;
                          isAttachmentSend = true;
                          videoFile = XFile(compressResult.path!);
                        });
                      }
                    }, 
                    icon: const Icon(Icons.movie, size: 30,)
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: (){
        
                    }, 
                    icon: const Icon(Icons.mic, size: 30,)
                  )
                ],
              ),
              if(uploadImages)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...listImages]
              ),
              if(uploadVideo)
              Container(
                height: 100,
                width: 100,
                color: Colors.black,
                child: const Icon(Icons.check, color: Colors.white,),
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
                        "attachmentType":attachmentTypeByBool(),
                        "attachmentUrl":downloadUrls.first,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                      });
                      debugPrint("Done");
                    } else if(uploadVideo){
                      List<String> downloadUrls = [];
                      Uint8List filesAsBytes = await videoFile!.readAsBytes();
                      List<Uint8List> result = [filesAsBytes];
                      for(Uint8List elem in result){
                        if(!mounted)return;
                        final TaskSnapshot upload = await FirebaseStorage.instance.ref(user.email).child(videoFile!.name+now.day.toString()+now.minute.toString()+now.year.toString()+now.minute.toString()+now.second.toString()).putData(elem, SettableMetadata(contentType: 'video/mp4'));
                        final String downloadUrl = await upload.ref.getDownloadURL();
                        downloadUrls.add(downloadUrl);
                      }
                      debugPrint(downloadUrls.toString());
                      await FirebaseFirestore.instance.collection("posts").add({
                        "attachmentType":attachmentTypeByBool(),
                        "attachmentUrl":downloadUrls.first,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                      });
                      debugPrint("Done");
                    } else if(uploadVoiceNote){
        
                    } else {
                      await FirebaseFirestore.instance.collection("posts").add({
                        "attachmentType":null,
                        "attachmentUrl":null,
                        "comments":[],
                        "content":content.text,
                        "datePost":DateTime.now(),
                        "likers":[],
                        "likes":0,
                        "owner":user.userRef,
                      });
                    }
                    setState(() {
                      isLoading = false;
                    });
                    if(!mounted)return;
                    await PopUp.okPopUp(
                      context: context, 
                      title: "Done", 
                      message: "You've posted successfully"
                    );
                    widget.navCallback(0);
                  }, 
                  child: const Text("Post")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}