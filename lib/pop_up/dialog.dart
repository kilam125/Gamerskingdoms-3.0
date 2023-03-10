import 'package:flutter/material.dart';

class GmkDialog {
  static Future<bool?> sendInvitation({
    required BuildContext context, 
    required String title, 
    required String hintText,
    String? explanation,
    required TextEditingController controller,
    required GlobalKey<FormState> formKey,
    required Future<dynamic> Function() callBack,
    String? Function(String?)? validator
  }) async {
    return showDialog<bool?>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return Form(
          key: formKey,
          child: AlertDialog(
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    if(formKey.currentState!.validate()){
                      callBack().then((value) => Navigator.of(context).pop(true));
                    }
                  },
                  child: const Text(
                    "Send"
                  ),
                ),
              )
            ],
            title: Center(
              child: Text(
                title
              )
            ),
            content:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(explanation!=null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(explanation),
                ),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText
                  ),
                  validator: validator,
                ),                
              ],
            )
          ),
        );
      }
    );
  }
}