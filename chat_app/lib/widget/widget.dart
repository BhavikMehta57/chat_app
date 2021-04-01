import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/services/auth.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/iso_battery_info.dart';

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
      new GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildbatterydialog(context),
          );
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.battery_unknown_sharp)),
      ),
      new GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.announcement)),
      ),
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

Widget _buildbatterydialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('Battery Info'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FutureBuilder<AndroidBatteryInfo>(
            future: BatteryInfoPlugin().androidBatteryInfo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    'Battery Health: ${snapshot.data.health
                        .toUpperCase()}');
              }
              return CircularProgressIndicator();
            }),
        StreamBuilder<AndroidBatteryInfo>(
            stream: BatteryInfoPlugin().androidBatteryInfoStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text("Voltage: ${(snapshot.data.voltage)} mV"),
                    Text(
                        "Charging status: ${(snapshot.data.chargingStatus
                            .toString().split(".")[1])}"),
                    Text(
                        "Battery Level: ${(snapshot.data.batteryLevel)} %"),
                    Text("Technology: ${(snapshot.data.technology)} "),
                    Text(
                        "Battery present: ${snapshot.data.present
                            ? "Yes"
                            : "False"} "),
                    Text("Scale: ${(snapshot.data.scale)} "),
                    Text(
                        "Remaining energy: ${-(snapshot.data.remainingEnergy * 1.0E-9)} Watt-hours"),
                    _getChargeTime(snapshot.data),
                  ],
                );
              }
              return CircularProgressIndicator();
            }),
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

Widget _getChargeTime(AndroidBatteryInfo data) {
  if (data.chargingStatus == ChargingStatus.Charging) {
    return data.chargeTimeRemaining == -1
        ? Text("Calculating charge time remaining")
        : Text(
        "Charge time remaining: ${(data.chargeTimeRemaining / 1000 / 60).truncate()} minutes");
  }
  return Text("Battery is full or not connected to a power source");
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
