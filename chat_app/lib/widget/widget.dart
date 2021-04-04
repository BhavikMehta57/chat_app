import 'package:flutter/material.dart';
import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/services/auth.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Text("CHATAPP"),
    leading: Image.asset(
      "assets/images/logo.png",
      height: 40,
    ),
    elevation: 0.0,
    actions: [
      GestureDetector(
        onTap: () {
          AuthService().signOut();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Authenticate()));
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.exit_to_app)),
      ),
    ],
    centerTitle: false,
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black26),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 18);
}
