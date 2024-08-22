
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/type_of_post.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/other_user_profile_view.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/widgets/audio_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final UserProfile user;
  final UserProfile moi;
  final bool latest;
  final bool fromNotifAbo;
  const PostWidget({
    super.key,
    required this.post,
    required this.user,
    required this.latest,
    required this.moi,
    this.fromNotifAbo = false, 
  });

  static Widget getPictureWidget(String url){
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
      
    );
  }

  Widget getVideoWidget(String url) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: VideoWidget(url: url),
    );
  }

   Widget attachementViewByType(AttachmentType? attachmentType, String? attachmentUrl){
    if(attachmentType == null || attachmentUrl == null){
      return Container();
    } else {
      if(attachmentType == AttachmentType.picture){
        return getPictureWidget(attachmentUrl);
      }
      else if(attachmentType == AttachmentType.video){
        return getVideoWidget(attachmentUrl);
      } else if(attachmentType == AttachmentType.audio){
        return AudioWidget(url: attachmentUrl);
      } else{
        return VoiceNoteWidget(url: attachmentUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProfile using = context.watch<UserProfile>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
          stream: post.owner.get().asStream(),
          builder: (context, ownerSnapshot){
            if(!ownerSnapshot.hasData || ownerSnapshot.data == null){
              return const ProgressWidget();
            } else {
              UserProfile user = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
              return GestureDetector(
                onTap: (){
/*                   Navigator.of(context).pushNamed(
                    OtherUserProfileView.routeName,
                    arguments: {
                      "user":user,
                      "me": using
                    }
                  ); */
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: OtherUserProfileView.routeName,
                      ),
                      builder: (context) => ListenableProvider.value(
                        value: using,
                        child: OtherUserProfileView(
                          user : user,
                          me : using
                        ),
                      )
                    )
                  );
                },
                child: Row(
                  children: [
                    Container(
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
                    Text(
                      user.displayName.capitalize(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    if(latest)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text("Latest"),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (details) async {
                        final offset = details.globalPosition;
                        // Utiliser PopupMenuButton
                        String? value = await showMenu<String>(
                          useRootNavigator: false,
                          context: context,
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy,
                            MediaQuery.of(context).size.width - offset.dx,
                            MediaQuery.of(context).size.height - offset.dy,
                          ),
                          items: [
                            if(post.owner != using.userRef)
                            const PopupMenuItem<String>(
                              value: 'report',
                              child: Text('Report'),
                            ),
                            if(post.owner != using.userRef)
                            const PopupMenuItem<String>(
                              value: 'block',
                              child: Text('Block user'),
                            ),
                            if(post.owner == using.userRef)
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        );
                        // Faire quelque chose avec la valeur retournée
                        if (value != null) {
                          if (value == 'report') {
                            // ignore: use_build_context_synchronously
                            var result = await PopUp.reportPopUp(
                              context: context, 
                              title: 'Report', 
                              message: 'Please select the reason for reporting this post', 
                              type: TypeOfPost.post,
                              okCallBack: (typeOfReport, typeOfPost, cmt) async {
                                return await FirebaseFirestore.instance.collection('reports').add({
                                  "date":Timestamp.now(),
                                  "isRequestProcessed":false,
                                  "post": post.postRef,
                                  "type": typeOfPost.index,
                                  "typeOfReport": typeOfReport.index,
                                  "userReported": post.owner,
                                  "userReporter": using.userRef,
                                  "cmt": cmt,
                                });
                              }
                            );
                            if(result != null && result){
                              PopUp.okPopUp(
                                context: context, 
                                title: "Done", 
                                message: "Post has been reported", 
                                okCallBack: () {}
                              );
                            }
                          } else if (value == 'delete') {
                            // ignore: use_build_context_synchronously
                            PopUp.yesNoPopUp(
                              context: context, 
                              title: "Wait..", 
                              message: "Are you sure you want to delete this post ?", 
                              yesCallBack: () async {
                                await post.postRef.delete();
                              }
                            );
                          } else if (value == 'block') {
                            // ignore: use_build_context_synchronously
                            PopUp.yesNoPopUp(
                              context: context, 
                              title: "Wait..", 
                              message: "Are you sure you want to block this user ?", 
                              yesCallBack: () async {
                                await using.blockUser(user);
                              }
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.more_vert, size: 30),
                    )
                  ],
                ),
              );
            }
          },
        ),
        if(post.content != null && post.content!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            post.content!,
            style: const TextStyle(
              fontSize: 16
            ),
          ),
        ),
        attachementViewByType(post.attachmentType, post.attachmentUrl),
        Row(
          children: [
            IconButton(
              onPressed: () async { 
                if(!post.likers.contains(using.userRef)){
                  await post.addLike(using.userRef);
                } else {
                  await post.removeLike(using.userRef);
                }
              }, 
              icon: Icon(
                post.likers.contains(using.userRef) ? Icons.star : Icons.star_border,
                color: post.likers.contains(using.userRef) ? const Color.fromARGB(255, 216, 174, 84) : Colors.black,
                size: 30,
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                "${post.likes} likes",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onTap: (){
              debugPrint("Tapped");
              if(true){
                log("Tapped from notif abo");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StreamProvider<List<Post>>.value(
                      initialData: [post],
                      value: Post.streamAPost(post),
                      builder: (context, c) {
                        return StreamProvider<UserProfile>.value(
                          initialData: moi,
                          value: UserProfile.streamUser(moi.userRef),
                          builder: (context, v) {
                            return PageComments(
                              userProfile: user,
                              postRef: post.postRef
                            );
                          }
                        );
                      }
                    )
                  )
                );
              } else {
                log("Tapped outside notif abo");
                Navigator.of(context).pushNamed(
                  PageComments.routeName,
                  arguments: {
                    "userProfile":user,
                    "postRef":post.postRef
                  }
                );
              }
            },
            child: Text(
              "Check ${post.comments.length} comments",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 62, 62, 62),
                decoration: TextDecoration.underline
              ),
            ),
          ),
        ),
      ],
    );
  }
}