import 'dart:async';

import 'package:flutter/material.dart';
import './loginscreen.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => loginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(

          child: Container(
            decoration: BoxDecoration(color: Colors.black),
            padding: EdgeInsets.only(top: 100),


            child: Column(
              children: [
                Image.asset('assets/images/BIBLogo.png'),
                Text('HealthCare Edition',style: TextStyle(fontSize: 20, color: Colors.white),)
              ],
            ),
          ),
        ));
  }
}
