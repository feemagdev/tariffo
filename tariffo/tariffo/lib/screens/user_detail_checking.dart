import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/HomePage.dart';
import 'package:tariffo/User.dart';
import 'package:tariffo/choosedBusinessUser.dart';
import 'package:tariffo/screens/customer_profile_screen.dart';
import 'package:tariffo/viewProfile.dart';

class BusinessUserCheck extends StatefulWidget {
  final String uid;

  const BusinessUserCheck({Key key, @required this.uid}) : super(key: key);

  @override
  _UserHandlingState createState() => _UserHandlingState();
}

class _UserHandlingState extends State<BusinessUserCheck> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future:
              Firestore.instance.collection('Users').document(widget.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data);
              if (user.userRole == 'Business') {
                if (user.country == null || user.country == "") {
                  return BusinessPage();
                } else {
                  return Homepage();
                }
              } else {
                return Homepage();
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
