import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:tariffo/chatScreen.dart';
import 'package:tariffo/messages_list.dart';

class ReadPostScreen extends StatefulWidget {
  final String currentUser;
  final String username;
  final DateTime dateTime;
  final String description;
  final String postID;
  final String postUser;

  const ReadPostScreen(
      {Key key,
      @required this.username,
      @required this.dateTime,
      @required this.description,
      @required this.currentUser,
      @required this.postID,
      @required this.postUser})
      : super(key: key);
  @override
  _ReadPostScreenState createState() => _ReadPostScreenState();
}

class _ReadPostScreenState extends State<ReadPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.username,
                          textScaleFactor: 1.2,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat.yMMMMd().format(widget.dateTime),
                          textScaleFactor: 1.1,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: SingleChildScrollView(
                        child: Text(
                          widget.description,
                          textScaleFactor: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FlatButton(
              onPressed: () async {
                DocumentSnapshot snapshot;
                snapshot = await Firestore.instance
                    .collection('Users')
                    .document(widget.postUser)
                    .get();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ChatScreen(
                    serviceProviderId: snapshot.documentID,
                    userName: snapshot.data['name'],
                    avatarUrl: snapshot.data['avatarUrl'],
                  );
                }));
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  "Message",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Visibility(
              visible: widget.currentUser == widget.postUser ? true : false,
              child: RaisedButton(
                onPressed: () {
                  Firestore.instance
                      .collection("post")
                      .document(widget.postID)
                      .delete();
                  Navigator.pop(context);
                },
                color: Colors.red[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.transparent,
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
