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
import 'package:carrier_info_s/carrier_info_s.dart';
import 'package:all_sensors/all_sensors.dart';
import 'dart:async';
import 'package:wifi_connection/WifiConnection.dart';
import 'package:wifi_connection/WifiInfo.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;
  CarrierData carrierInfo;
  WifiInfo _wifiInfo = WifiInfo();
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  bool _proximityValues = false;
  List <StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];


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

  Future<void> initPlatformState() async {

    WifiInfo wifiInfo;

    wifiInfo = await WifiConnection.wifiInfo;


    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _wifiInfo = wifiInfo;
    });
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      carrierInfo = await CarrierInfo.all;
      setState(() {});
    } catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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

        "Accelerometer":'${accelerometer}',
        "UserAccelerometer":'${userAccelerometer}',
        "Gyroscope":'${gyroscope}',
        "Proximity":'${_proximityValues}',

        "SSID":'${_wifiInfo.ssid}',
        "BSSID": '${_wifiInfo.bssId}',
        "IP": '${_wifiInfo.ipAddress}',
        "MAC Address": '${_wifiInfo.macAddress}',
        "Link Speed": '${_wifiInfo.linkSpeed}',
        "Signal Strength": '${_wifiInfo.signalStrength}',
        "Frequency": '${_wifiInfo.frequency}',
        "Channel": '${_wifiInfo.channel}',
        "Network Id": '${_wifiInfo.networkId}',
        "IsHiddenSSID": '${_wifiInfo.isHiddenSSid}',
        "Router IP": '${_wifiInfo.routerIp}',

        "Carrier Allows VOIP": carrierInfo?.allowsVOIP,
        "Carrier Name": carrierInfo?.carrierName,
        "Carrier ISO Country Code": carrierInfo?.isoCountryCode,
        "Carrier Mobile Country Code": carrierInfo?.mobileCountryCode,
        "Carrier Mobile Network Operator": carrierInfo?.mobileNetworkOperator,
        "Carrier Mobile Network Code": carrierInfo?.mobileNetworkCode,
        "Carrier Network Generation": carrierInfo?.networkGeneration,
        "Carrier Radio Type": carrierInfo?.radioType,

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

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    getUserInfogetChats();
    initPlatformState();

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

    deviceinfo();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
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
