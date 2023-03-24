import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/add_posts.dart';
import 'package:gamers_kingdom/database_service.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/posts.dart';
import 'package:gamers_kingdom/profile.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

class PageComments extends StatefulWidget {
  final Post post;
  const PageComments({
    required this.post,
    super.key
  });
  static String routeName = "/Dashboard";
  @override
  State<PageComments> createState() => _PageCommentsState();
}

class _PageCommentsState extends State<PageComments> {
  final formKey = GlobalKey<FormState>();
  int activeIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
    );
  }
}