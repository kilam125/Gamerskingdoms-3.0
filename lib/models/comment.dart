
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/util/util.dart';

class Comment{
  final DocumentReference ref;
  final DocumentReference commentator;
  final DocumentReference post;
  final bool attachmentPresent;
  final DateTime date;
  final String? content;
  final String? attachmentUrl;
  final AttachmentType? attachmentType;

  const Comment(
    {
      required this.ref,
      required this.commentator,
      required this.post,
      required this.attachmentPresent,
      required this.date,
      this.attachmentUrl,
      this.attachmentType,
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
      "attachmentType":Util.attachmentTypeToInt(attachmentType),
      "content":content,
      "visible":true
    };
  }

  factory Comment.fromFirestore({required DocumentSnapshot doc}){
    return Comment(
      ref: doc.reference,
      commentator: doc["commentator"], 
      post: doc["post"], 
      attachmentPresent: doc["attachmentPresent"],
      date: (doc["date"] as Timestamp).toDate(),
      content: doc["content"],
      attachmentUrl: doc["attachmentUrl"],
      attachmentType:Util.intToAttachmentType(doc["attachmentType"]),
    );
  }
}