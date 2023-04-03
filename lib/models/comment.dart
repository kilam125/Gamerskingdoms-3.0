
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final DocumentReference commentator;
  final DocumentReference post;
  final bool attachmentPresent;
  final DateTime date;
  final String? content;
  final String? attachmentUrl;

  const Comment(
    {
      required this.commentator,
      required this.post,
      required this.attachmentPresent,
      required this.date,
      this.attachmentUrl,
      this.content
    }
  );

  toJson(){
    return {
      "commentator":commentator,
      "post":post,
      "attachmentPresent":attachmentPresent,
      "date":date,
      "attachmentUrl":attachmentUrl,
      "content":content
    };
  }

  factory Comment.fromFirestore({required DocumentSnapshot doc}){
    return Comment(
      commentator: doc["commentator"], 
      post: doc["post"], 
      attachmentPresent: doc["attachmentPresent"],
      date: (doc["date"] as Timestamp).toDate(),
      content: doc["content"],
      attachmentUrl: doc["attachmentUrl"]
    );
  }
}