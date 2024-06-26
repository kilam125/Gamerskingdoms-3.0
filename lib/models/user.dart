import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/util/util.dart';

class UserProfile extends ChangeNotifier {
  String? picture;
  String displayName;
  List<Skills> skills;
  List? followers;
  List? following;
  String? bio;
  String email;
  DocumentReference userRef;
  List? friendRequest;
  List fcmTokens;
  List<DocumentReference> blockedUsers;
  get getFcmTokens => fcmTokens;

  void addFcmTokens(String token){
    fcmTokens.add(token);
    notifyListeners();
  }
  get getUserRef => userRef;

  get getPicture => picture;

 set setPicture(picture) {
   this.picture = picture;
   notifyListeners();
 }

  get getDisplayName => displayName;

 set setDisplayName(displayName) {
    this.displayName = displayName;
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

 set setBio( bio) => this.bio = bio;

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

  Future<void> blockUser(UserProfile profile) async {
    log("$displayName blocked user ${profile.displayName}");
    log("Blocked user ${profile.displayName}");
    Future removeInFollowers = userRef.set({
        "followers":FieldValue.arrayRemove([profile.userRef]),
        "blockedUsers":FieldValue.arrayUnion([profile.userRef])
      },
      SetOptions(
        merge: true
      )
    );
    Future removeInFollowing = profile.userRef.set({
        "following":FieldValue.arrayRemove([userRef]),
      },
      SetOptions(
        merge: true
      )
    );
    await Future.wait([removeInFollowers, removeInFollowing]);
    notifyListeners();
  }

  Future<void> addFollower(DocumentReference friend) async {
    followers!.add(friend);
    await userRef.set({
      "followers":FieldValue.arrayUnion([friend])
      },
      SetOptions(
        merge: true
      )
    );
    notifyListeners();
  }

  Future<void> removeFollower(DocumentReference friend) async {
    followers!.remove(friend);
    await userRef.set({
      "followers":FieldValue.arrayRemove([friend])
      },
      SetOptions(
        merge: true
      )
    );
    notifyListeners();
  }

  Future<void> addFollowing(DocumentReference friend) async {
    following!.add(friend);
    await userRef.set({
      "following":FieldValue.arrayUnion([friend])
      },
      SetOptions(
        merge: true
      )
    );
    notifyListeners();
  }

  Future<void> removeFollowing(DocumentReference friend) async {
    following!.remove(friend);
    await userRef.set({
      "following":FieldValue.arrayRemove([friend])
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
    List<String> skillsToWrite = this.skills.map((e) => Util.skillsToString(e)).toList();
    await userRef.set({
      "displayName":displayName,
      "skills":skillsToWrite,
      "picture":picture,
      "bio":bio
    },
    SetOptions(merge: true)
  );
    QuerySnapshot result = await FirebaseFirestore.instance.collection("posts").where("owner", isEqualTo: userRef).where("visible", isEqualTo: true).get();
    await Future.forEach(
      result.docs, (element) => element.reference.update(
        {
          "skills":skillsToWrite
        }
      )
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
    this.friendRequest,
    this.fcmTokens = const [],
    this.blockedUsers = const []
  });

  static Future<DocumentReference> createFriendRequest({required DocumentReference requester, required DocumentReference target}) async {
    return FirebaseFirestore.instance.collection("friendRequest")
      .add({
        "requester":requester,
        "target":target,
        "date":DateTime.now()
      });
  }
  static Stream<UserProfile> streamUser(DocumentReference user){
    return user.snapshots().map((event) => UserProfile.fromFirestore(data: event));
  }

  factory UserProfile.fromFirestore({required DocumentSnapshot data}){
    Map dataMap = data.data() as Map;
    try {
      return UserProfile(
        email: dataMap["email"],
        displayName: dataMap["displayName"], 
        skills: (dataMap["skills"] as List).map((e) => Util.stringToSkills(e)).toList(),
        picture: dataMap["picture"],
        bio: data["bio"],
        followers: dataMap.containsKey("followers") ? dataMap["followers"] : [],
        following: dataMap.containsKey("following") ? dataMap["following"] : [],
        friendRequest: dataMap.containsKey("friendRequest") ? dataMap["friendRequest"] : [],
        userRef: data.reference,
        fcmTokens: dataMap.containsKey("fcmTokens") ? dataMap["fcmTokens"] : [],
        blockedUsers: dataMap.containsKey("blockedUsers") ? List<DocumentReference>.from(dataMap["blockedUsers"]) : []
      );
    } catch (e) {
      log("Error in UserProfile.fromFirestore: ${data.id}");
      return UserProfile(
        email: "",
        displayName: "", 
        skills: [],
        picture: "",
        bio: "",
        followers: [],
        following: [],
        friendRequest: [],
        userRef: (FirebaseFirestore.instance.collection("users").doc("")),
        fcmTokens: [],
        blockedUsers: []
      );
    }
  }

/*   factory UserProfile.fromJson({required Map dataMap}){
    return UserProfile(
      email: dataMap["email"],
      displayName: dataMap["displayName"], 
      skills: (dataMap["skills"] as List).map((e) => Util.stringToSkills(e)).toList(),
      picture: dataMap["picture"],
      bio: dataMap["bio"],
      followers: dataMap.containsKey("followers") ? dataMap["followers"] : [],
      following: dataMap.containsKey("following") ? dataMap["following"] : [],
      friendRequest: dataMap.containsKey("friendRequest") ? dataMap["friendRequest"] : [],
      userRef: DocumentReference(),
      fcmTokens: dataMap.containsKey("fcmTokens") ? dataMap["fcmTokens"] : []
    );
  } */
}