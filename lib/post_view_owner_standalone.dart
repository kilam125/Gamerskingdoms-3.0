import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/comments_view_standalone.dart';
import 'package:gamers_kingdom/enums/attachment_type.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/main.dart';
import 'package:gamers_kingdom/models/post.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/page_comments.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:gamers_kingdom/widgets/video_widget.dart';
import 'package:gamers_kingdom/widgets/voice_note_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PostViewOwnerStandalone extends StatefulWidget {
  final Post post;
  final UserProfile viewer;
  final bool ownUser = true;
  const PostViewOwnerStandalone({
    super.key,
    required this.post,
    required this.viewer
  });
  static const String routeName = "/PostViewOwnerStandalone";
  @override
  State<PostViewOwnerStandalone> createState() => _PostViewOwnerStandaloneState();
}

class _PostViewOwnerStandaloneState extends State<PostViewOwnerStandalone> {

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
      appBar: AppBar(),
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
          stream: widget.post.postRef.snapshots(),
          builder: (context, postSnapshot) {
            if(!postSnapshot.hasData){
              return const ProgressWidget();
            }
            Post post = Post.fromFirestore(data: postSnapshot.data!);
            return StreamBuilder(
              stream: widget.post.owner.get().asStream(),
              builder: (context, ownerSnapshot) {
                bool hasAttachment = (post.attachmentType != null && post.attachmentUrl != null);
                if(ownerSnapshot.data == null){
                  return const SizedBox(
                    height: 300,
                    width: 300,
                    child: Center(child: ProgressWidget())
                  );
                }
                UserProfile user = UserProfile.fromFirestore(data: ownerSnapshot.data!);
                return Column(
                  mainAxisSize: MainAxisSize.min,
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
                    attachementViewByType(post.attachmentType!, post.attachmentUrl!),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async { 
                            if(!post.likers.contains(widget.viewer.userRef)){
                              await post.addLike(widget.viewer.userRef);
                            } else {
                              await post.removeLike(widget.viewer.userRef);
                            }
                          }, 
                          icon: Icon(
                            post.likers.contains(widget.viewer.userRef) ? Icons.star : Icons.star_border,
                            color: post.likers.contains(widget.viewer.userRef) ? const Color.fromARGB(255, 216, 174, 84) : Colors.black,
                            size: 30,
                          )
                        ),
                        IconButton(
                          onPressed: () async {
                            navigatorKey.currentState!.push(
                              MaterialPageRoute(
                                settings: RouteSettings(
                                  name: PageComments.routeName,
                                ),
                                builder: (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider<UserProfile>.value(
                                      value: widget.viewer
                                    ),
                                    StreamProvider<List<Post>>.value(
                                      value: Post.streamAPost(post),
                                      updateShouldNotify:(oldList,currentList) => (currentList!=oldList),
                                      initialData: [post],
                                    ),
                                  ],
                                  builder: (context, child) {
                                    return PageComments(
                                      postRef: post.postRef,
                                      userProfile: user,
                                    );
                                  }
                                )
                              )
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
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(
                              settings: RouteSettings(
                                name: PageComments.routeName,
                              ),
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider<UserProfile>.value(
                                    value: widget.viewer
                                  ),
                                  StreamProvider<List<Post>>.value(
                                    value: Post.streamAPost(post),
                                    updateShouldNotify:(oldList,currentList) => (currentList!=oldList),
                                    initialData: [post],
                                  ),
                                ],
                                builder: (context, child) {
                                  return PageComments(
                                    postRef: post.postRef,
                                    userProfile: user,
                                  );
                                }
                              )
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
                  ],
                );
              }
            );
          }
        ),
      )
    );
  }
}