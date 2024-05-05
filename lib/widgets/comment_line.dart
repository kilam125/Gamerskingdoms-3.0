
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/type_of_post.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/other_user_profile_view.dart';
import 'package:gamers_kingdom/own_profile_view.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/profile_view_standalone.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';

import '../models/comment.dart';

class CommentLine extends StatelessWidget {
  final Comment comment;
  final DocumentSnapshot<Object?>? postOwner;
  final bool nested;
  final UserProfile myself;
  const CommentLine(
    {
      super.key,
      required this.comment,
      required this.myself,
      this.nested = false,
      this.postOwner
    });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: comment.commentator.snapshots(),
      builder: (context, userSnapshot) {
        if(!userSnapshot.hasData){
          return const SizedBox(
            height: 30,
            width: 30,
            child: ProgressWidget()
          );
        }
        UserProfile user = UserProfile.fromFirestore(data: userSnapshot.data!);
        if(myself.blockedUsers.contains(user.userRef)){
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 208, 208, 208),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  if(!nested){
                    Navigator.of(context).pushNamed(
                      OtherUserProfileView.routeName,
                      arguments: {
                        "user":user,
                        "me": myself
                      }
                    );
                  } else {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name:ProfileViewStandalone.routeName,
                        ),
                        builder: (context) => ProfileViewStandalone(
                          followerData : UserProfile.fromFirestore(data: userSnapshot.data!),
                          recipientData : UserProfile.fromFirestore(data: postOwner!)
                        )
                      )
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      flex: 8,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 4,
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
                            child: Text(
                              user.displayName.capitalize(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right:16.0),
                        child: GestureDetector(
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
                                if(comment.commentator != myself.userRef)
                                const PopupMenuItem<String>(
                                  value: 'report',
                                  child: Text('Report'),
                                ),
                                if(comment.commentator == myself.userRef)
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                                if(comment.commentator != myself.userRef)
                                const PopupMenuItem<String>(
                                  value: 'block',
                                  child: Text('Block user'),
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
                                  message: 'Please select the reason for reporting this comment', 
                                  type: TypeOfPost.comment,
                                  okCallBack: (typeOfReport, typeOfPost, cmt) async {
                                    return await FirebaseFirestore.instance.collection('reports').add({
                                      "date":Timestamp.now(),
                                      "isRequestProcessed":false,
                                      "post": comment.ref,
                                      "type": typeOfPost.index,
                                      "typeOfReport": typeOfReport.index,
                                      "userReported": comment.commentator,
                                      "userReporter": myself.userRef,
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
                                  message: "Are you sure you want to delete this comment ?", 
                                  yesCallBack: () async {
                                    await comment.ref.delete();
                                  }
                                );
                              } else if(value == 'block'){
                                await myself.blockUser(user);
                              }
                            }
                          },
                          child: const Icon(Icons.more_vert, size: 25),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if(comment.content!=null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(comment.content!),
              ),
              if(comment.attachmentType == AttachmentType.voice && comment.attachmentUrl != null)
              VoiceNoteWidget(url: comment.attachmentUrl!)
            ],
          ),
        );
      }
    );
  }
}