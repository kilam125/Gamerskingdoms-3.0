// NM Custom Text Field V2

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GmkTextField extends StatefulWidget {
  final String title;
  final String defaultText;
  final String hintText;
  final void Function(String) onChanged;
  final void Function()? onFocus;
  final void Function()? onDone;
  final TextInputType inputType;
  final bool obscure;
  final EdgeInsets edges;
  final bool capitalize;
  final int? maxLength;
  final TextStyle titleTextStyle;
  final TextStyle hintTextStyle;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final TextEditingController controller;
  const GmkTextField(
    {
      Key? key,
      required this.controller,
      required this.title,
      this.defaultText = '',
      this.hintText = '',
      this.onDone,
      this.onFocus,
      this.validator,
      this.titleTextStyle = const TextStyle(
        color:  Color(0xff000000),
        fontSize: 20,
        fontWeight: FontWeight.w200
      ),
      this.hintTextStyle = const TextStyle(
        color:  Color(0xff000000),
        fontSize: 20,
        fontWeight: FontWeight.w200
      ),
      this.textInputType = TextInputType.text,
      required this.onChanged,
      this.inputType = TextInputType.text,
      this.obscure = false,
      this.capitalize = true,
      this.maxLength,
      this.edges = const EdgeInsets.only(bottom: 5, top: 1, left: 1)
    }
  )
      : super(key: key);

  @override
  GmkTextFieldState createState() => GmkTextFieldState();
}

class GmkTextFieldState extends State<GmkTextField> {
  Color borderColor = const Color(0xffa0a0a0);
  final Color fillColor = const Color.fromARGB(255, 187, 186, 186);
  FocusNode focus = FocusNode();
  TextEditingController textCtrl = TextEditingController();

  String lastText = "";

  @override
  void initState() {
    textCtrl.text = widget.defaultText;
    super.initState();
  }

  @override
  void dispose() {
    textCtrl.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 5, left: 12),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall,
          )
        ),
        TextFormField(
          validator: widget.validator,
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.maxLength),
            widget.inputType == TextInputType.datetime
              ? FilteringTextInputFormatter.allow(RegExp("([0-9])|/"))
              : FilteringTextInputFormatter.singleLineFormatter
          ],
          controller: textCtrl,
          focusNode: focus,
          textInputAction: TextInputAction.done,
          keyboardType: widget.inputType,
          textAlign: TextAlign.left,
          showCursor: true,
          obscureText: widget.obscure,
          autocorrect: false,
          textCapitalization: widget.capitalize ? TextCapitalization.words : TextCapitalization.none,
          enableSuggestions: false,
          cursorColor: const Color(0xff000000),
          cursorHeight: 18,
          /* decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).focusColor,
            isCollapsed: true,
            hintText: widget.hintText,
            hintStyle: widget.hintTextStyle,
            contentPadding: widget.edges,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            border: Theme.of(context).inputDecorationTheme.border,
          ), */
          style: Theme.of(context).textTheme.headlineSmall,
          onChanged: widget.onChanged,
        ),
      ]
    );
  }
}
