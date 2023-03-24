

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/widgets/post_widget.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/post.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

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

  Widget attachementViewByType(AttachmentType attachmentType, String attachmentUrl){
    if(attachmentType == AttachmentType.picture){
      return getPictureWidget(attachmentUrl);
    }
    else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProfile using = context.watch<UserProfile>();
    return StreamProvider<List<Post>>.value(
      value:Post.streamAllPosts(),
      updateShouldNotify:(oldList,currentList) => (currentList!=oldList),
      initialData:const [],
      builder: (context, child){
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder(
                    stream: post.owner.get().asStream(),
                    builder: (context, ownerSnapshot){
                      if(ownerSnapshot.data == null){
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
                          Icons.thumb_up,
                          color: post.likers.contains(using.userRef) ? Colors.blue : Colors.black,
                        )
                      ),
                      IconButton(
                        onPressed: () async { 
                          // await post.addLike(user.ref);
                        }, 
                        icon: const Icon(Icons.add_comment)
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return PageComments(post: post);    
                            }
                          )
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(post.content!),
                  ),
                ],
              ),
            );
          },
          // itemCount: context.watch<List<Post>>().length,
          itemCount: context.watch<List<Post>>().length,
        );
      },
    );
  }
}