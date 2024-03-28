import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:permission_handler/permission_handler.dart';

class Util{
  static void askMicrophoneOrOpenSettings() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      // If permission is not granted, request it
      var result = await Permission.microphone.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        // If permission is denied or permanently denied, open app settings
        AppSettings.openAppSettings();
      }
    }
  }
  static Future<bool> askMicrophone() async {
    var status = await Permission.microphone.status;
    log("Status : $status");
    if (status.isGranted) {
      return true;
    } else if(!status.isPermanentlyDenied){
      var result = await Permission.microphone.request();
      return result.isGranted;
    } else {
      return false;
    }
  }
  static Future<String?> convertToMp3(String inputFilePath) async {
    final outputFile = inputFilePath.replaceAll('.aac', '.mp3');
    final command = '-i $inputFilePath -y -c:a libmp3lame $outputFile';
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
      case "fighting_spirit":
        return Skills.fightingSpirit;
      case "loyal":
        return Skills.loyal;
      case "cooperative":
        return Skills.cooperative;
      case "altruist":
        return Skills.altruist;
      case "achiever":
        return Skills.achiever;
      case "artist":
        return Skills.artist;
      case "creative":
        return Skills.creative;
      case "eccentric":
        return Skills.eccentric;
      case "mysterious":
        return Skills.mysterious;
      case "storyteller":
        return Skills.storyteller;
      case "secret":
        return Skills.secret;
      case "up_for_it":
        return Skills.upForIt;
      case '\u{1F601}':
        return Skills.smile;
      case '\u{1F913}':
        return Skills.nerd;
      case '\u{1F602}':
        return Skills.laugh;
      case '\u{1F643}':
        return Skills.angel;
      case '\u{1FAE0}':
        return Skills.reverseFace;
      case '\u{1F644}':
        return Skills.melted;
      case '\u{1FAE3}':
        return Skills.rolling;
      case '\u{1F629}':
        return Skills.hiding;
      case '\u{1F972}':
        return Skills.lasse;
      case '\u{1F61B}':
        return Skills.cry;
      case '\u{1F608}':
        return Skills.tongue;
      case '\u{1F607}':
        return Skills.devil;
      case '\u{1F92A}':
        return Skills.crazyTongue;
      case '\u{1F621}':
        return Skills.angry;
      case '\u{2764}':
        return Skills.heart;
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
      case Skills.fightingSpirit:
        return "Fighting Spirit";
      case Skills.loyal:
        return "Loyal";
      case Skills.cooperative:
        return "Cooperative";
      case Skills.altruist:
        return "Altruist";
      case Skills.achiever:
        return "Achiever";
      case Skills.artist:
        return "Artist";
      case Skills.creative:
        return "Creative";
      case Skills.eccentric:
        return "Eccentric";
      case Skills.mysterious:
        return "Mysterious";
      case Skills.storyteller:
        return "Storyteller";
      case Skills.secret:
        return "Secret";
      case Skills.upForIt:
        return 'Up For It';
      case Skills.smile:
        return '\u{1F601}';
      case Skills.nerd:
        return '\u{1F913}';
      case Skills.laugh:
        return '\u{1F602}';
      case Skills.angel:
        return '\u{1F643}';
      case Skills.reverseFace:
        return '\u{1FAE0}';
      case Skills.melted:
        return '\u{1F644}';
      case Skills.rolling:
        return '\u{1FAE3}';
      case Skills.hiding:
        return '\u{1F629}';
      case Skills.lasse:
        return '\u{1F972}';
      case Skills.cry:
        return '\u{1F61B}';
      case Skills.tongue:
        return '\u{1F608}';
      case Skills.devil:
        return '\u{1F607}';
      case Skills.crazyTongue:
        return '\u{1F92A}';
      case Skills.angry:
        return '\u{1F621}';
      case Skills.heart:
        return '\u{2764}';
      default:
        return "Unknown";
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