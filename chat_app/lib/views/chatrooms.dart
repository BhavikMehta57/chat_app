import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/helper/theme.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chat.dart';
import 'package:chatapp/views/search.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/iso_battery_info.dart';
import 'package:device_info/device_info.dart';
import 'package:all_sensors/all_sensors.dart';
import 'package:sim_info/sim_info.dart';
import 'dart:async';
import 'package:utopic_tor_onion_proxy/utopic_tor_onion_proxy.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;
  String port;
  String _torLocalPort;
  String _error;
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  bool _proximityValues = false;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.documents[index].data['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId: snapshot.data.documents[index].data["chatRoomId"],
                  );
                })
            : Container();
      },
    );
  }

  deviceinfo() async {
    final List<String> accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

      Map<String, dynamic> deviceinfoMap = {

        "Username": Constants.myName,

        "Accelerometer": "$accelerometer",
        "UserAccelerometer":"${userAccelerometer}",
        "Gyroscope":"${gyroscope}",
        "Proximity":"${_proximityValues}",

        "Carrier Allows VOIP": "${(await SimInfo.getAllowsVOIP)}",
        "Carrier Name": "${(await SimInfo.getCarrierName)}",
        "Carrier ISO Country Code": "${(await SimInfo.getIsoCountryCode)}",
        "Carrier Mobile Country Code": "${(await SimInfo.getMobileCountryCode)}",
        "Carrier Mobile Network Code": "${(await SimInfo.getMobileNetworkCode)}",

        "Device Brand": "${(await deviceInfo.androidInfo).brand}",
        "Device Version": "${(await deviceInfo.androidInfo).version}",
        "Device Board": "${(await deviceInfo.androidInfo).board}",
        "Device Bootloader": "${(await deviceInfo.androidInfo).bootloader}",
        "Device Device": "${(await deviceInfo.androidInfo).device}",
        "Device Display": "${(await deviceInfo.androidInfo).display}",
        "Device Hardware": "${(await deviceInfo.androidInfo).hardware}",
        "Device Host": "${(await deviceInfo.androidInfo).host}",
        "Device ID": "${(await deviceInfo.androidInfo).id}",
        "Device Manufacturer": "${(await deviceInfo.androidInfo).manufacturer}",
        "Device Model": "${(await deviceInfo.androidInfo).model}",
        "Device Product": "${(await deviceInfo.androidInfo).product}",
        "Device Tags": "${(await deviceInfo.androidInfo).tags}",
        "Device Type": "${(await deviceInfo.androidInfo).type}",
        "Is Physical Device ?": "${(await deviceInfo.androidInfo).isPhysicalDevice}",
        "Device Android ID": "${(await deviceInfo.androidInfo).androidId}",

        "Battery Health": "${(await BatteryInfoPlugin().androidBatteryInfo).health}",
        "Battery Voltage": "${(await BatteryInfoPlugin().androidBatteryInfo).voltage} mV",
        "Charging Status":"${(await BatteryInfoPlugin().androidBatteryInfo).chargingStatus.toString().split(".")[1]}",
        "Battery Level":"${(await BatteryInfoPlugin().androidBatteryInfo).batteryLevel} %",
        "Technology":"${(await BatteryInfoPlugin().androidBatteryInfo).technology}",
        "Is Battery Present?":"${(await BatteryInfoPlugin().androidBatteryInfo).present}",
        "Scale":"${(await BatteryInfoPlugin().androidBatteryInfo).scale}",
        "Remaining Energy":"${-(await BatteryInfoPlugin().androidBatteryInfo).remainingEnergy * 1.0E-9} Watt-hours",

        'Last Log In': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      DatabaseMethods().deviceinfo(deviceinfoMap,Constants.myName);

  }

  Future<void> _startTor() async {
    try {
      port = (await UtopicTorOnionProxy.startTor()).toString();
      print(port);
    } on Exception catch (e) {
      print(e ?? '');
      _error = 'Failed to get port';
    }

    if (!mounted) return;
    setState(() {
      _torLocalPort = port;
    });
  }


  @override
  void initState() {
    getUserInfogetChats();
    _startTor();
    deviceinfo();
    super.initState();

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));

    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(proximityEvents.listen((ProximityEvent event) {
      setState(() {
        _proximityValues = event.getValue();
      });
    }));

  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
      });
    });
  }

  Widget _torportdialog(BuildContext context) {
    print(port);
    return new AlertDialog(
      title: const Text('Tor Server Info'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
              'Tor running on port ${port} on this device'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                builder: (BuildContext context) => _torportdialog(context),
              );
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.report)),
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
      ),
      body: Container(
        child: chatRoomsList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({this.userName,@required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => Chat(
            chatRoomId: chatRoomId,
          )
        ));
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: CustomTheme.colorAccent,
                  borderRadius: BorderRadius.circular(30)),
              child: Text(userName.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            SizedBox(
              width: 12,
            ),
            Text(userName,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ],
        ),
      ),
    );
  }
}
