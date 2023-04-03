

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/profile_view.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'models/post.dart';

class Posts extends StatefulWidget {
  final Function(int) navCallback;
  const Posts({
    super.key,
    required this.navCallback
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

  List<XFile> listXFileImages = [];
  XFile? videoFile; 
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Widget getPictureWidget(String url){
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

  Widget attachementViewByType(AttachmentType attachmentType, String attachmentUrl){
    if(attachmentType == AttachmentType.picture){
      return getPictureWidget(attachmentUrl);
    }
    else if(attachmentType == AttachmentType.video){
      return getVideoWidget(attachmentUrl);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProfile using = context.watch<UserProfile>();
    return ListView.builder(
      itemBuilder: (context, index){
        debugPrint("Index $index");
        // Post post = Post.fromFirestore(data: snapshot.data!.docs[index]);
        Post post = context.watch<List<Post>>()[index];
        return Container(
          margin: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 223, 222, 222),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: StreamBuilder(
            stream: post.owner.get().asStream(),
            builder: (context, ownerSnapshot) {
              if(ownerSnapshot.data == null){
                return const ProgressWidget();
              }
              UserProfile user = UserProfile.fromFirestore(data:  ownerSnapshot.data!);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pushNamed(
                              ProfileView.routeName,
                              arguments: {
                                "user":user
                              }
                            );
                          },
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
                  if(post.attachmentType != null && post.attachmentUrl != null)
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
                          Icons.star_outline_sharp,
                          color: post.likers.contains(using.userRef) ? Colors.blue : Colors.black,
                          size: 30,
                        )
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.pushNamed(
                            context, 
                            PageComments.routeName,
                            arguments: {
                              "index":index,
                              "userProfile":user
                            }
                          );
                        }, 
                        icon: const Icon(
                          Icons.add_comment,
                          size: 30,
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
                    child: Text(post.content!),
                  ),
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
          ),
        );
      },
      // itemCount: context.watch<List<Post>>().length,
      itemCount: context.watch<List<Post>>().length,
    );
  }
}