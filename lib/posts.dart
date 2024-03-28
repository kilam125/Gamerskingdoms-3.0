

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/enums/type_of_post.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/filtered_skills.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/other_user_profile_view.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/audio_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'models/post.dart';

class Posts extends StatefulWidget {
  final Function(int) navCallback;
  const Posts({
    super.key,
    required this.navCallback,
  });

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  TextEditingController content = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isAttachmentSend = false;
  bool isLoading = false;

  bool uploadImages = false;
  bool uploadVideo = false;
  bool uploadVoiceNote = false;
  DateTime date = DateTime.now();

  List<XFile> listXFileImages = [];
  XFile? videoFile; 
  final player = AudioPlayer(); // Create a player

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose(){
    debugPrint("Dispose");
    super.dispose();
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
    } else if(attachmentType == AttachmentType.audio){
      return AudioWidget(url: attachmentUrl);
    } else if(attachmentType == AttachmentType.voice){
      return VoiceNoteWidget(url: attachmentUrl);
    }
    return Container();
  }
  
  @override
  Widget build(BuildContext parentContext) {
    UserProfile using = parentContext.watch<UserProfile>();
    FilteredSkills filter = Provider.of<FilteredSkills>(parentContext);
    List<Post> posts;
    if(filter.getSkills.isEmpty){
      posts = parentContext.watch<List<Post>>();
    } else {
      posts = parentContext.watch<List<Post>>().where((post) {
        List<String> ff = filter.getSkills.map((e) => Util.skillsToString(e)).toList();
        bool retour = post.skills.any((elem) {
          return ff.contains(elem);
        });
        return retour;
      }).toList();
    }
    if(posts.isEmpty){
      return const Center(child: Text("No Post found"),);
    }
    return ListView.builder(
      itemBuilder: (context, index){
        debugPrint("Index $index");
        Post post = posts[index];
        bool hasAttachment = (post.attachmentType != null && post.attachmentUrl != null);
        return Container(
          constraints: BoxConstraints(
            minHeight:Util.heightByAttachmentType(post.attachmentType),
          ),
          width: 375,
          margin: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 223, 222, 222),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: StreamBuilder(
            stream: post.owner.get().asStream(),
            builder: (context, ownerSnapshot) {
              if(ownerSnapshot.data == null){
                return const SizedBox(
                  height: 300,
                  width: 300,
                  child: Center(child: ProgressWidget())
                );
              }
              UserProfile user = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                        title: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pushNamed(
                              OtherUserProfileView.routeName,
                              arguments: {
                                "user":user,
                                "ownUser":false
                              }
                            );
                          },
                          child: Text(
                            user.displayName.capitalize(),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        trailing: GestureDetector(
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
                                if(post.owner == using.userRef)
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Supprimer'),
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
                                  okCallBack: (typeOfReport, typeOfPost) async {
                                    return await FirebaseFirestore.instance.collection('reports').add({
                                      "date":Timestamp.now(),
                                      "isRequestProcessed":true,
                                      "post": post.postRef,
                                      "type": typeOfPost.index,
                                      "typeOfReport": typeOfReport.index,
                                      "userReported": post.owner,
                                      "userReporter": using.userRef,
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
                              }
                            }
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                  ),
                  if(hasAttachment)
                  attachementViewByType(post.attachmentType!, post.attachmentUrl!),
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
                      IconButton(
                        onPressed: () async {
                          Navigator.pushNamed(
                            context, 
                            PageComments.routeName,
                            arguments: {
                              "postRef":post.postRef,
                              "index":index,
                              "userProfile":user
                            }
                          );
                        }, 
                        icon: const Icon(
                          Icons.add_comment,
                          size: 28,
                        )
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "${post.likes} likes",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExpandableText(
                      post.content ?? "",
                      expandText: 'Show more',
                      collapseText: 'Show less',
                      style: const TextStyle(
                        fontSize: 16
                      ), 
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pushNamed(
                          PageComments.routeName,
                          arguments: {
                            "postRef":post.postRef,
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
          ),
        );
      },
      // itemCount: context.watch<List<Post>>().length,
      itemCount:posts.length
    );
  }
}