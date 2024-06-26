import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/comment_line.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';

import 'models/comment.dart';

class CommentViewStandalone extends StatefulWidget {
  final Post post;
  final Comment comment;
  final bool ownUser = true;
  final UserProfile myself;
  const CommentViewStandalone({
    super.key,
    required this.post,
    required this.comment,
    required this.myself
  });
  static const String routeName = "/CommentViewStandalone";
  @override
  State<CommentViewStandalone> createState() => _CommentViewStandaloneState();
}

class _CommentViewStandaloneState extends State<CommentViewStandalone> {
  @override
  void initState() {
    super.initState();
  }


  Widget getPictureWidget(String url){
    return Container(
      constraints: const BoxConstraints(
        minHeight: 400,
        maxHeight: 401,
        maxWidth: double.infinity,
        minWidth: 300
      ),
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        height: 300,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget getVideoWidget(String url) {
    return VideoWidget(url: url);
  }

  Widget attachementViewByType(AttachmentType attachmentType, String attachmentUrl){
    if(attachmentType == AttachmentType.picture){
      return getPictureWidget(attachmentUrl);
    }
    else if(attachmentType == AttachmentType.video){
      return getVideoWidget(attachmentUrl);
    } else {
      //return Container(height: 300, width: 300, color: Colors.purple);
      return VoiceNoteWidget(url: attachmentUrl);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Comments"),
      ),
      body: Container(
        constraints: BoxConstraints(
          minHeight:Util.heightByAttachmentType(widget.post.attachmentType),
        ),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 223, 222, 222),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: StreamBuilder(
          stream: widget.post.owner.get().asStream(),
          builder: (context, ownerSnapshot) {
            bool hasAttachment = (widget.post.attachmentType != null && widget.post.attachmentUrl != null);
            if(ownerSnapshot.data == null){
              return const SizedBox(
                height: 300,
                width: 300,
                child: Center(child: ProgressWidget())
              );
            }
            UserProfile user = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle
                        ),
                        child: user.picture == null ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "assets/images/userpic.png", 
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            ),
                          )
                          :ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            user.picture!,
                            fit: BoxFit.fill,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: GestureDetector(
                        onTap: () async {},
                        child: Text(
                          user.displayName.capitalize(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Container(color: Colors.green)
                    )
                  ],
                ),
                if(hasAttachment)
                attachementViewByType(widget.post.attachmentType!, widget.post.attachmentUrl!),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Text(
                    "${widget.post.likes} likes",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if(widget.post.content != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExpandableText(
                    widget.post.content ?? "",
                    expandText: 'Show more',
                    collapseText: 'Show less',
                    style: const TextStyle(
                      fontSize: 16
                    ), 
                  ),
                ),
                const Divider(color: Colors.grey,),
                CommentLine(
                  comment: widget.comment,
                  nested: true,
                  postOwner: ownerSnapshot.data!,
                  myself: widget.myself,
                ),
                if(widget.comment.attachmentType == AttachmentType.voice && widget.comment.attachmentUrl != null)
                VoiceNoteWidget(url: widget.comment.attachmentUrl!),
                const SizedBox(height: 15,)
              ],
            );
          }
        ),
      )
    );
  }
}