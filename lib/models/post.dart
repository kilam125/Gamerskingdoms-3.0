import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/util/util.dart';

class Post{
  DocumentReference owner;
  List<DocumentReference?>? comments;
  String? content;
  DateTime datePost;
  AttachmentType? attachmentType;
  String? attachmentUrl;

  get getAttachmentType => attachmentType;

 set setAttachmentType( attachmentType) => this.attachmentType = attachmentType;

  get getAttachmentUrl => attachmentUrl;

 set setAttachmentUrl( attachmentUrl) => this.attachmentUrl = attachmentUrl;


  get getOwner => owner;

 set setOwner( owner) => owner = owner;

  get getComments => comments;

 set setComments( comments) => comments = comments;

  get getContent => content;

 set setContent( content) => content = content;

  get getDatePost => datePost;

 set setDatePost( datePost) => datePost = datePost;

  Post({
    required this.owner,
    required this.comments,
    required this.content,
    required this.datePost,
    this.attachmentType,
    this.attachmentUrl
  });

  factory Post.fromFirestore({required DocumentSnapshot data}){
    return Post(
      comments: data["comments"], 
      content: data["content"],
      datePost: data["date"],
      owner: data["owner"],
      attachmentType:Util.intToAttachmentType(data["attachmentType"]),
      attachmentUrl: data["attachmentUrl"]
    );
  }
}