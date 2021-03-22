import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Text("CHATAPP"),
    leading: Image.asset(
      "assets/images/logo.png",
      height: 40,
    ),
    elevation: 0.0,
    actions: [

      IconButton(icon:Icon(Icons.announcement), onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => _buildPopupDialog(context),
        );},)
    ],
    centerTitle: false,
  );
}

Widget _buildPopupDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('Device Info'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FutureBuilder<AndroidDeviceInfo>(future: deviceInfo.androidInfo,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            AndroidDeviceInfo info = snapshot.data;
            return Container(
                child: Column(
                  children: [
                    Text("Brand: ${info.brand}"),
                    Text("Version: ${info.version}"),
                    Text("Board: ${info.board}"),
                    Text("Bootloader: ${info.bootloader}"),
                    Text("Device: ${info.device}"),
                    Text("Display: ${info.display}"),
                    Text("Hardware: ${info.hardware}"),
                    Text("Host: ${info.host}"),
                    Text("id: ${info.id}"),
                    Text("Manufacturer: ${info.manufacturer}"),
                    Text("Model: ${info.model}"),
                    Text("Product: ${info.product}"),
                    Text("Tags: ${info.tags}"),
                    Text("Type: ${info.type}"),
                    Text("Is Physical Device ? ${info.isPhysicalDevice}"),
                    Text("AndroidID: ${info.androidId}"),
                  ],
                )
            );
          }
          return CircularProgressIndicator();
        })
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Close'),
      ),
    ],
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
