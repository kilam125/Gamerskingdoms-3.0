import 'package:gamers_kingdom/enums/skills.dart';

class Util{
  static Skills stringToSkills(String str){
    switch (str.toLowerCase().trim()){
      case "leader":
        return Skills.leader;
      case "accomplisher":
        return Skills.accomplisher;
      case "strategist":
        return Skills.strategist;
      case "explorer":
        return Skills.explorer;
      case "challenger":
        return Skills.challenger;
      case "shooter":
        return Skills.shooter;
      case "attacker":
        return Skills.attacker;
      case "hardcore":
        return Skills.hardcore;
      case "roleplayer":
        return Skills.roleplayer;
      case "rpg":
        return Skills.rpg;
      case "mmo":
        return Skills.mmo;
      case "team":
        return Skills.team;
      case "solo":
        return Skills.solo;
      case "professional":
        return Skills.professional;
      case "passionate":
        return Skills.passionate;
      case "cool":
        return Skills.cool;
      case "noob":
        return Skills.noob;
      case "troll":
        return Skills.troll;
      default:
        return Skills.noob;
    }
  }
  static String skillsToString(Skills str){
    switch (str){
      case Skills.leader:
        return "Leader";
      case Skills.accomplisher:
        return "Accomplisher";
      case Skills.strategist:
        return "Strategist";
      case Skills.explorer:
        return "Explorer";
      case Skills.challenger:
        return "Challenger";
      case Skills.shooter:
        return "Shooter";
      case Skills.attacker:
        return "Attacker";
      case Skills.hardcore:
        return "Hardcore";
      case Skills.roleplayer:
        return "Roleplayer";
      case Skills.cosplayer:
        return "Cosplayer";
      case Skills.rpg:
        return "Rpg";
      case Skills.mmo:
        return "Mmo";
      case Skills.team:
        return "Team";
      case Skills.solo:
        return "Solo";
      case Skills.professional:
        return "Professional";
      case Skills.passionate:
        return "Passionate";
      case Skills.cool:
        return "Cool";
      case Skills.noob:
        return "Noob";
      case Skills.troll:
        return "Troll";
    }
  }
}