import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/models/user.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

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
  List<String> skills = List.generate(Skills.values.length, (index) => Skills.values[index].name.capitalize());
  List<String> selectedSkills = [];
  late final List<MultiSelectItem<String>> items;

  @override
  void initState() {
    super.initState();
    displayName.text = widget.user.displayName;
    selectedSkills  = widget.user.skills.map((e) => e.toString()).toList();
    items = skills
      .map((skill) => MultiSelectItem<String>(skill, skill))
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
        title: const Text("My profile"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: user.picture == null ?
                        Image.asset(
                          "assets/images/userpic.png", 
                          height: 200,
                          width: 200
                        )
                      :Image.network(
                        user.picture!,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 213, 213, 213),
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.edit, color: Colors.black,)
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Display Name")
                  ),
                  controller: displayName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Bio")
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
                    MultiSelectDialogField<String>(
                      items: items,
                      title: const Text("Skills"),
                      selectedColor: Colors.blue,
                      buttonIcon: const Icon(
                        Icons.manage_accounts,
                        color: Colors.blue,
                      ),
                      buttonText: Text(
                        "Choose your skills",
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
            ],
          ),
        ),
      ),
    );
  }
}