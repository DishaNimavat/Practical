import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_practical_aveosoft/screens/home_screen.dart';
import 'package:flutter_practical_aveosoft/utils/app_color.dart';
import 'package:provider/provider.dart';

///Purpose: Splash Screen which is entry point

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

///Purpose: To set the flow whether to navigate login screen / onboarding screen / dashboard screen

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Container(
            decoration: new BoxDecoration(color: AppColor.appWhite),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  SizedBox(
                    height: 80.0,
                    child: Image.asset(
                      "assets/images/img_logo.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ]))),
      ),
    );
  }
}
