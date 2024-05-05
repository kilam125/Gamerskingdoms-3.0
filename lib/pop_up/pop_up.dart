import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gamers_kingdom/enums/type_of_post.dart';
import 'package:gamers_kingdom/enums/type_of_report.dart';

class PopUp{
static Future reportPopUp({
  required BuildContext context, 
  required String title, 
  required String? message, 
  Function(TypeOfReport, TypeOfPost, String)? okCallBack, // Adjusted to accept a String parameter
  required TypeOfPost type
}) {
  TypeOfReport selectedReport = TypeOfReport.inappropriateContent;
  TextEditingController textEditingController = TextEditingController(text: '');

  return showPlatformDialog(
    useRootNavigator: false,
    barrierDismissible: true,
    context: context,
    builder: (context) => Material(
      color: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, ss) {
          return PlatformAlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min, // To prevent overflow
              children: [
                RadioListTile<TypeOfReport>(
                  title: const Text('Inappropriate content'),
                  value: TypeOfReport.inappropriateContent,
                  groupValue: selectedReport,
                  onChanged: (TypeOfReport? value) {
                    ss(() {
                      selectedReport = value!;
                    });
                  },
                ),
                RadioListTile<TypeOfReport>(
                  title: const Text('Copyright violation'),
                  value: TypeOfReport.copyrightViolation,
                  groupValue: selectedReport,
                  onChanged: (TypeOfReport? value) {
                    ss(() {
                      selectedReport = value!;
                    });
                  },
                ),
                TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Additional information",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              PlatformDialogAction(
                child: PlatformText("OK"),
                onPressed: () {
                  if (okCallBack != null) {
                    okCallBack(selectedReport, type, textEditingController.text);
                  }
                  Navigator.pop(context, true);
                },
              ),
              PlatformDialogAction(
                child: PlatformText("Cancel"),
                onPressed: () => Navigator.pop(context, false),
              )
            ],
          );
        }
      ),
    ),
  );
}

  
  static Future okPopUp({required BuildContext context, required String title, required String? message, Function()? okCallBack}){
    return showPlatformDialog(
      useRootNavigator: false,
      barrierDismissible: true,
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message!),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText("OK"),
            onPressed: () {
              if(okCallBack!=null){
                okCallBack();
              }
              Navigator.pop(context);
            }
          )
        ],
      ),
    );
  }

  static Future yesNoPopUp({required BuildContext context, required String title, required String? message, required Future<dynamic> Function() yesCallBack}){
    return showPlatformDialog(
      useRootNavigator: false,
      barrierDismissible: true,
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message!),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText("Yes"),
            onPressed: (){
              yesCallBack().then((value) => Navigator.pop(context,value));
            }
          ),
          PlatformDialogAction(
            child: PlatformText("Cancel"),
            onPressed: () => Navigator.pop(context)
          )
        ],
      ),
    );
  }
}