
import 'package:flutter/material.dart';

class DeleteEntryButton extends StatelessWidget {
  const DeleteEntryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      width: 80,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(244, 92, 92, 1),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Text(
        "Delete Post",
        style: TextStyle(fontSize:14,fontWeight:FontWeight.w200,color:Colors.white)
,
      ),
    );
  }
}