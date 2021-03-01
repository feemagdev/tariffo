import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/User.dart';
import 'package:tariffo/screens/customer_profile_screen.dart';
import 'package:tariffo/viewProfile.dart';

class UserHandling extends StatefulWidget {
  final String uid;

  const UserHandling({Key key, @required this.uid}) : super(key: key);

  @override
  _UserHandlingState createState() => _UserHandlingState();
}

class _UserHandlingState extends State<UserHandling> {
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
              if (user.userRole == 'Customer') {
                return CustomerProfileScreen(userID: user.uid);
              } else {
                return StoryProfile(
                  uid: widget.uid,
                  currentUserID: widget.uid,
                );
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
