import 'package:flutter/material.dart';

class UnknownRoute extends StatefulWidget {
  final String route;
  const UnknownRoute({
    super.key,
    this.route = "Test"
  });
  static String routeName = "/UnknownRoute";
  @override
  State<UnknownRoute> createState() => _UnknownRouteState();
}

class _UnknownRouteState extends State<UnknownRoute> {
  @override
  Widget build(BuildContext context) {
    Map? mp = (ModalRoute.of(context)!.settings.arguments as Map?);
    return Scaffold(
      body:mp==null ?  Text("UnknownRoute ${widget.route}") :  Text(" $mp"),
    );
  }
}