import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  final UserProfile user;
  const Profile({
    super.key,
    required this.user
  });
  static const String routeName = "/Profile";
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final formKey = GlobalKey<FormState>();
  TextEditingController displayName = TextEditingController();
  TextEditingController bio = TextEditingController();
  List<Skills> skills = List.generate(Skills.values.length, (index) => Skills.values[index]);
  List<Skills> selectedSkills = [];
  late final List<MultiSelectItem<Skills>> items;
  bool isLoading = false;
  bool isLoadingButton = false;
  
  @override
  void initState() {
    super.initState();
    displayName.text = widget.user.displayName;
    debugPrint("Selected Skills ${selectedSkills.toString()}");
    debugPrint("User Skills ${widget.user.skills.toString()}");
    selectedSkills  = widget.user.skills;
    items = skills
      .map((skill) => MultiSelectItem<Skills>(skill, Util.skillsToString(skill)))
      .toList();
    if(widget.user.bio != null){
      bio.text = widget.user.bio!;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    UserProfile user = context.watch<UserProfile>();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: (){
              FirebaseAuth.instance.signOut();
            },
          )
        ],
        title: const Text("My profile"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle
                        ),
                        child: user.picture == null ?
                          Image.asset(
                            "assets/images/userpic.png", 
                            fit: BoxFit.fill,
                            height: 200,
                            width: 200,
                          )
                        :Image.network(
                          user.picture!,
                          fit: BoxFit.fill,
                          height: 200,
                          width: 200,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        var result = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                        if(result != null){
                          setState(() {
                            isLoading = true;
                          });
                          final file = await result.readAsBytes();
                          final TaskSnapshot upload = await FirebaseStorage.instance.ref(widget.user.email).putData(file, SettableMetadata(contentType: 'image/jpeg'));
                          final String downloadUrl = await upload.ref.getDownloadURL();
                          setState(() {
                            isLoading = false;
                          });
                          user.picture = downloadUrl;
                        }
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: isLoading ?
                        const ProgressWidget():
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 213, 213, 213),
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.edit, color: Colors.black,)
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 12, left: 12),
                      label: Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text("Display Name"),
                      )
                    ),
                    controller: displayName,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 16, left: 12),
                      label: Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text("Bio"),
                      ),
                    ),
                    controller: bio,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 5, left: 12),
                        child: Text(
                          "Your Skills",
                          style: Theme.of(context).inputDecorationTheme.labelStyle,
                        )
                      ),
                      MultiSelectDialogField<Skills>(
                        initialValue: selectedSkills,
                        items: items,
                        selectedItemsTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue
                        ),
                        itemsTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black
                        ),
                        title: const Text("Skills"),
                        selectedColor: Colors.blue,
                        buttonIcon: const Icon(
                          Icons.manage_accounts,
                          color: Colors.blue,
                        ),
                        buttonText: Text(
                          "Your skills",
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                          ),
                        ),
                        onConfirm: (results) {
                          selectedSkills = results;
                        },
                      ),
                    ],
                  ),
                ),
                !isLoadingButton ?
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoadingButton = true;
                    });
                    user.setDisplayName = displayName.text;
                    user.bio = bio.text;
                    user.skills = selectedSkills;
                    await user.setUser(
                      displayName: user.displayName.toLowerCase(),
                      skills: selectedSkills, 
                      picture: user.picture, 
                      bio: user.bio!
                    );
                    if(!mounted)return;
                    Navigator.of(context).pop();
                  }, 
                  child: const Text("Send")
                ):
                const ProgressWidget(),
                ElevatedButton(
                  onPressed: () async {
                    const url = 'https://gamerskingdoms.com/mention/';
                    // launch url here
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: const Text("GCU")
                ),
                ElevatedButton(
                  onPressed: () async {
                    PopUp.yesNoPopUp(
                      context: context, 
                      title: "Wait...", 
                      message: "Are you sure you want to delete your account ?", 
                      yesCallBack: () async {
                        await user.userRef.update({
                          "name": "Deleted",
                          "surname": "User",
                          "displayName": "Deleted User",
                        });
                        await FirebaseFunctions.instance.httpsCallable("disableAccount").call({
                          "email": user.email
                        });
                        FirebaseAuth.instance.signOut();
                      }
                    );
                  }, 
                  child: const Text("Delete my account")
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}