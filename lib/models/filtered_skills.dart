import 'package:flutter/foundation.dart';
import 'package:gamers_kingdom/enums/skills.dart';

class FilteredSkills extends ChangeNotifier {
  List<Skills> selectedSkills = [];

  List<Skills> get getSkills => selectedSkills;

  void addSkillsToList(List<Skills> item) {
    selectedSkills.addAll(item);
    debugPrint(selectedSkills.toString());
    notifyListeners();
  }

  void resetSkills() {
    selectedSkills.clear();
    notifyListeners();
  }
}