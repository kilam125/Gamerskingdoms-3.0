import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PopUp{
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