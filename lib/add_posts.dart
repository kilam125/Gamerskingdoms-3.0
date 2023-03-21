

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPosts extends StatefulWidget {
  const AddPosts({super.key});

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

  List<String> images = [];
  List<XFile> listXFileImages = [];
  
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
                    var result = await picker.pickMultiImage(imageQuality: 30);
                    if(result.isNotEmpty){
                      setState(() {
                        uploadImages = true;
                        isAttachmentSend = true;
                        listXFileImages = result;
                      });

                    }
                  }, 
                  icon: const Icon(Icons.image, size: 30,)
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: (){

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
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  if(uploadImages){
                    List<String> downloadUrls = [];
                    List<Future<Uint8List>> filesAsBytes = listXFileImages.map((e) {
                      return e.readAsBytes();
                    }).toList();
                    List<Uint8List> result = await Future.forEach(filesAsBytes, (element) async => await element);
                    for(Uint8List elem in result){
                      if(!mounted)return;
                      final TaskSnapshot upload = await FirebaseStorage.instance.ref(user.email).putData(elem, SettableMetadata(contentType: 'image/jpeg'));
                      final String downloadUrl = await upload.ref.getDownloadURL();
                      downloadUrls.add(downloadUrl);
                    }

                    FirebaseFirestore.instance.collection("posts").add({
                      "content":content.text,
                      "attachmentType":attachmentTypeByBool(),
                      "date":DateTime.now(),
                      "attachmentUrl":downloadUrls,
                      "owner":user.userRef
                    });
                  } else if(uploadVideo){

                  } else if(uploadVoiceNote){

                  }
                  setState(() {
                    isLoading = true;
                  });
                }, 
                child: const Text("Post")
              ),
            )
          ],
        ),
      ),
    );
  }
}