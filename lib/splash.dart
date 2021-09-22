import 'dart:async';

import 'package:dhatnoon/LoginNew.dart';
import 'package:dhatnoon/constants.dart';
import 'package:flutter/material.dart';

import 'landing.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginNew())));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text(
            'DHATNOON',
            style: TextStyle(
                fontSize: 40, color: login_bg, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
