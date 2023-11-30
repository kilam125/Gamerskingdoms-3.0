import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/skills.dart';

class Util{

  static   Future<String?> convertToMp3(String inputFilePath) async {
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
    return null;
  }
  
  static Future<String> uploadFileToFirebaseStorage(String pathToUpload, File file) async {
    Uint8List filesAsBytes = await (file).readAsBytes();
    final TaskSnapshot upload = await FirebaseStorage.instance
      .ref(pathToUpload)
      .putData(
        filesAsBytes, 
        SettableMetadata(contentType: 'audio/mp3')
      );
    final String downloadUrl = await upload.ref.getDownloadURL();
    return downloadUrl;
  }
  static Skills stringToSkills(String str){
    switch (str.toLowerCase().trim()){
      case "leader":
        return Skills.leader;
      case "accomplisher":
        return Skills.accomplisher;
      case "strategist":
        return Skills.strategist;
      case "explorer":
        return Skills.explorer;
      case "challenger":
        return Skills.challenger;
      case "shooter":
        return Skills.shooter;
      case "attacker":
        return Skills.attacker;
      case "hardcore":
        return Skills.hardcore;
      case "roleplayer":
        return Skills.roleplayer;
      case "rpg":
        return Skills.rpg;
      case "mmo":
        return Skills.mmo;
      case "team":
        return Skills.team;
      case "solo":
        return Skills.solo;
      case "professional":
        return Skills.professional;
      case "passionate":
        return Skills.passionate;
      case "cool":
        return Skills.cool;
      case "noob":
        return Skills.noob;
      case "troll":
        return Skills.troll;
      default:
        return Skills.noob;
    }
  }

  static String skillsToString(Skills str){
    switch (str){
      case Skills.leader:
        return "Leader";
      case Skills.accomplisher:
        return "Accomplisher";
      case Skills.strategist:
        return "Strategist";
      case Skills.explorer:
        return "Explorer";
      case Skills.challenger:
        return "Challenger";
      case Skills.shooter:
        return "Shooter";
      case Skills.attacker:
        return "Attacker";
      case Skills.hardcore:
        return "Hardcore";
      case Skills.roleplayer:
        return "Roleplayer";
      case Skills.cosplayer:
        return "Cosplayer";
      case Skills.rpg:
        return "Rpg";
      case Skills.mmo:
        return "Mmo";
      case Skills.team:
        return "Team";
      case Skills.solo:
        return "Solo";
      case Skills.professional:
        return "Professional";
      case Skills.passionate:
        return "Passionate";
      case Skills.cool:
        return "Cool";
      case Skills.noob:
        return "Noob";
      case Skills.troll:
        return "Troll";
    }
  }

  static AttachmentType? intToAttachmentType(int? num){
    if(num == 0){
      return AttachmentType.picture;
    }
    if(num == 1){
      return AttachmentType.video;
    }
    if(num == 2){
      return AttachmentType.voice;
    }
    if(num == 3){
      return AttachmentType.audio;
    }
    return null;
  }

  static int? attachmentTypeToInt(AttachmentType? num){
    if(num == AttachmentType.picture){
      return 0;
    }
    if(num == AttachmentType.video){
      return 1;
    }
    if(num == AttachmentType.voice){
      return 2;
    }
    if(num == AttachmentType.audio){
      return 3;
    }
    return null;
  }

  static double heightByAttachmentType(AttachmentType? attachmentType){
    debugPrint("attachment type is : $attachmentType");
    if(attachmentType == AttachmentType.picture){
      return 400;
    }
    else if(attachmentType == AttachmentType.video){
      return 650;
    } else {
      return 300;
    }
  }

}