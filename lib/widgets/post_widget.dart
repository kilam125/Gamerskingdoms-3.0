
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final UserProfile user;
  final int index;
  const PostWidget({
    super.key,
    required this.post,
    required this.user,
    required this.index
  });

  static Widget getPictureWidget(String url){
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.fill,
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
    }
    else if(attachmentType == AttachmentType.picture){
      return getPictureWidget(attachmentUrl);
    } else if(attachmentType == AttachmentType.video){
      return getVideoWidget(attachmentUrl);
    } else if(attachmentType == AttachmentType.voice){
      return VoiceNoteWidget(url: attachmentUrl);
    }
    return Container();
  }
  @override
  Widget build(BuildContext context) {
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
              return Row(
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
                  Text(
                    user.displayName.capitalize(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      DateFormat.yMMMMd().format(post.datePost)
                    ),
                  )
                ],
              );
            }
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 1,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed(
                PageComments.routeName,
                arguments: {
                  "index":index,
                  "userProfile":user
                }
              );
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