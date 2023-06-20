
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:gamers_kingdom/profile_view_standalone.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';

import '../models/comment.dart';

class CommentLine extends StatelessWidget {
  final Comment comment;
  final DocumentSnapshot<Object?>? postOwner;
  final bool nested;
  const CommentLine(
    {
      super.key,
      required this.comment,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                if(!nested){
                  Navigator.of(context).pushNamed(
                    ProfileView.routeName,
                    arguments: {
                      "user":user
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
                    flex: 1,
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
                                  height: 30,
                                  width: 30,
                                ),
                              )
                              :ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                user.picture!,
                                fit: BoxFit.fill,
                                height: 30,
                                width: 30,
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
/*                   Flexible(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(right:16.0),
                      child: Text(
                        ""//DateFormat.yMMMMd().format(comment.date)
                      ),
                    ),
                  ) */
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
        );
      }
    );
  }
}