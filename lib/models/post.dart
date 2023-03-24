import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/util/util.dart';

class Post extends ChangeNotifier {
  DocumentReference owner;
  List comments;
  String? content;
  DateTime datePost;
  AttachmentType? attachmentType;
  String? attachmentUrl;
  int likes;
  List likers;
  DocumentReference postRef;

  List get getLikers => likers;

  Future<void> addLike(DocumentReference ref) async {
    likes++;
    likers.add(ref);
    notifyListeners();
    await postRef.set(
      {
        "likes":likes,
        "likers":FieldValue.arrayUnion([ref])
      },
      SetOptions(merge: true)
    );
  }

  Future<void> removeLike(DocumentReference ref) async {
    likes--;
    likers.remove(ref);
    notifyListeners();
    await postRef.set(
      {
        "likes":likes,
        "likers":FieldValue.arrayRemove([ref])
      },
      SetOptions(merge: true)
    );
  }

 set setLikers(List<DocumentReference> likers) => this.likers = likers;

  get getLikes => likes;

 set setLikes( likes) => this.likes = likes;

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
    required this.postRef,
    required this.owner,
    required this.comments,
    required this.content,
    required this.datePost,
    this.attachmentType,
    this.attachmentUrl,
    this.likes = 0,
    this.likers = const []
  });

  factory Post.fromFirestore({required DocumentSnapshot data}){
    return Post(
      postRef: data.reference,
      comments: data["comments"], 
      content: data["content"],
      datePost: (data["datePost"] as Timestamp).toDate(),
      owner: data["owner"],
      attachmentType:Util.intToAttachmentType(data["attachmentType"]),
      attachmentUrl: data["attachmentUrl"],
      likes: data["likes"] ?? 0,
      likers: data["likers"] ?? []
    );
  }

  static Stream<List<Post>> streamAllPosts(){
    Query posts = FirebaseFirestore.instance.collection("posts").orderBy("datePost", descending: true);
    return posts.snapshots().map(
      (listOfPosts) {
        debugPrint("list of clients : ${listOfPosts.docs.length.toString()}");
        return listOfPosts.docs.map((e) => Post.fromFirestore(data:e)).toList();
      });
  }
}