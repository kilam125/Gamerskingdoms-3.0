import 'package:flutter/material.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/util/util.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class Filter extends StatefulWidget {
  const Filter({
    super.key,
  });
  static String routeName = "/Filter";
  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  TextEditingController bio = TextEditingController();
  List<Skills> skills = List.generate(Skills.values.length, (index) => Skills.values[index]);
  List<Skills> selectedSkills = [];
  late final List<MultiSelectItem<Skills>> items;
  
  @override
  void initState() {
    super.initState();
    items = skills
      .map((skill) => MultiSelectItem<Skills>(skill, Util.skillsToString(skill)))
      .toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search profile by skills"),
      ),
      body: ListView(
        children: [
          MultiSelectDialogField<Skills>(
            initialValue: selectedSkills,
            items: items,
            title: const Text("Skills"),
            selectedColor: Colors.blue,
            buttonIcon: const Icon(
              Icons.manage_accounts,
              color: Colors.blue,
            ),
            buttonText: Text(
              "Choose the skills",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 16,
              ),
            ),
            onConfirm: (results) {
              selectedSkills = results;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 100, right: 100),
            child: ElevatedButton(
              onPressed: () async {
                if(skills.isNotEmpty){
                  Navigator.of(context).pop(selectedSkills);
                } else {
                  PopUp.okPopUp(
                    context: context, 
                    title: "Wait !", 
                    message: "You need to select at least one skills"
                  );
                }
              }, 
              child: const Text("Search")
            ),
          )
        ],
      ),
    );
  }
}