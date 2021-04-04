import 'package:chatapp/views/signin.dart';
import 'package:chatapp/views/signup.dart';
import 'package:flutter/material.dart';
import 'package:utopic_tor_onion_proxy/utopic_tor_onion_proxy.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  String _torLocalPort;

  Future<void> _stopTor() async {
    try {
      if (await UtopicTorOnionProxy.stopTor()) {
        if (!mounted) return;
        setState(() {
          _torLocalPort = null;
        });
      }
    } on Exception catch (e) {
      print(e ?? '');
    }
  }

  @override
  void initState() {
    _stopTor();
    super.initState();
  }

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(toggleView);
    } else {
      return SignUp(toggleView);
    }
  }
}
