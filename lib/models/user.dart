import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';

class UserProfile extends ChangeNotifier {
  final String? picture;
  final String displayName;
  final List<Skills> skills;
  final List<DocumentReference?>? followers;
  final List<DocumentReference?>? following;
  final String? bio;
  final String email;

  UserProfile({
    required this.displayName,
    required this.skills,
    required this.email,
    this.picture,
    this.followers,
    this.following,
    this.bio
  });

  factory UserProfile.fromFirestore({required DocumentSnapshot data}){
    Map dataMap = data.data() as Map;
    return UserProfile(
      email: dataMap["email"],
      displayName: dataMap["displayName"], 
      skills: [],
      picture: dataMap["picture"],
      bio: data["bio"],
      followers: dataMap.containsKey("followers") ? dataMap["followers"] : [],
      following: dataMap.containsKey("following") ? dataMap["following"] : []
    );
  }
}