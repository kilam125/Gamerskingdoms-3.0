import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamers_kingdom/models/user.dart';

class DatabaseService{
  static streamUser(String id){
    return FirebaseFirestore.instance
      .collection("users")
      .doc(id)
      .get()
      .asStream()
      .map((userData) => UserProfile.fromFirestore(data:userData));
  }
}