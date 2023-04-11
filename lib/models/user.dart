import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/util/util.dart';

class UserProfile extends ChangeNotifier {
  String? picture;
  String displayName;
  List<Skills> skills;
  List<DocumentReference?>? followers;
  List<DocumentReference?>? following;
  String? bio;
  String email;
  DocumentReference userRef;
  List? friendRequest;

  get getUserRef => userRef;

  get getPicture => picture;

 set setPicture(picture) {
   picture = picture;
   notifyListeners();
 }

  get getDisplayName => displayName;

 set setDisplayName(displayName) {
    displayName = displayName;
    notifyListeners();
 }

  get getSkills => skills;

 set setSkills(skills) {
   this.skills = skills;
   notifyListeners();
 }


  get getFollowers => followers;

 set setFollowers( followers) => followers = followers;

  get getFollowing => following;

 set setFollowing( following) => following = following;

  get getBio => bio;

 set setBio( bio) => bio = bio;

  get getEmail => email;

 set setEmail( email) => email = email;

  Future<void> setFriendRequest(DocumentReference friendRequest) async {
    this.friendRequest!.add(friendRequest);
    await userRef.set({
      "friendRequest":FieldValue.arrayUnion([friendRequest])
      },
      SetOptions(
        merge: true
      )
    );
    notifyListeners();
  }
 Future<void> setUser({
    required String displayName,
    required List<Skills> skills,
    required String? picture,
    required String bio
  }) async {
    await userRef.set({
      "displayName":displayName,
      "skills":this.skills.map((e) => Util.skillsToString(e)).toList(),
      "picture":picture,
      "bio":bio
    },
    SetOptions(merge: true)
  );
 }

  UserProfile({
    required this.displayName,
    required this.skills,
    required this.email,
    required this.userRef,
    this.picture,
    this.followers,
    this.following,
    this.bio,
    this.friendRequest
  });

  static Future<DocumentReference> createFriendRequest({required DocumentReference requester, required DocumentReference target}) async {
    return FirebaseFirestore.instance.collection("friendRequest")
      .add({
        "requester":requester,
        "target":target,
        "date":DateTime.now()
      });
  }
  factory UserProfile.fromFirestore({required DocumentSnapshot data}){
    Map dataMap = data.data() as Map;
    return UserProfile(
      email: dataMap["email"],
      displayName: dataMap["displayName"], 
      skills: (dataMap["skills"] as List).map((e) => Util.stringToSkills(e)).toList(),
      picture: dataMap["picture"],
      bio: data["bio"],
      followers: dataMap.containsKey("followers") ? dataMap["followers"] : [],
      following: dataMap.containsKey("following") ? dataMap["following"] : [],
      friendRequest: dataMap.containsKey("friendRequest") ? dataMap["friendRequest"] : [],
      userRef: data.reference
    );
  }
}