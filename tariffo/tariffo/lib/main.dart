import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tariffo/auth.dart';
import 'package:tariffo/provider_widget.dart';
import 'package:tariffo/push_notification_service.dart';
import 'package:tariffo/screens/user_detail_checking.dart';
import 'dart:async';
import 'LoginScreen.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String email;
  SharedPreferences sharedPrefs;

  initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((value) {
      if (value == null) {
        new Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ));
      } else {
        new Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BusinessUserCheck(
                            uid: value.uid,
                          )),
                ));
      }
    });

//    _getPrefs().then((value) {
//      print('in getPrefs');
//      if (value == '') {
//        print('value is empty');
//        new Future.delayed(
//            const Duration(seconds: 1),
//            () => Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => LoginScreen()),
//                ));
//      } else {
//        print('value is not empty');
//        new Future.delayed(
//            const Duration(seconds: 1),
//            () => Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => Homepage()),
//                ));
//      }
//    });
  }

  Future<String> _getPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
    email = sharedPrefs.getString('email') ?? '';

    return email;
  }

  Future<void> _rmPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.remove('masterAuth');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Provider(
        auth: Authentication(),
        db: Firestore.instance,
        child: MaterialApp(
          title: 'Welcome to Flutter',
          home: Scaffold(
              backgroundColor: Colors.blue,
              body: Center(
                child: Text(
                  "Tariffo",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SignPainter',
                      fontSize: 60),
                ),
              )),
        ));
  }
}
