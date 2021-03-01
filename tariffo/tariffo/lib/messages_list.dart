import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/chatScreen.dart';
import 'package:tariffo/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  String currentName, currentProfile;
  Stream messageListStream;
  String spliteId2;

  List<Message> messagess = [];
  List<String> msgIds = [];
  List<String> msgNames;
  List<String> msgUrls;
  HashMap<String, Message> lastMsg = new HashMap();
  Message eachMessage;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String currentId;
  String otherUserId;
  String otherUserName;
  String otherAvatarUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseAuth.currentUser().then((value) {
      print("My id according to fire auth: ${value.uid}");
      Firestore.instance
          .collection("Users")
          .document(value.uid)
          .get()
          .then((value) {
        currentName = value.data['name'];
        currentId = value.documentID;
        currentProfile = value.data['avatarUrl'];
        retrieveMessageList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: lastMsg.length > 0
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                  itemCount: lastMsg.length,
                  itemBuilder: (context, int index) {
                    otherUserId = msgIds[index];
                    print("List item $index : $otherUserId");
                    otherUserName = msgNames[index];
                    otherAvatarUrl = msgUrls[index];
                    print(
                        "current otheruserid: $otherUserId length of msgs: ${lastMsg.length}\n${lastMsg.keys}");
                    eachMessage = lastMsg[otherUserId];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                      serviceProviderId: msgIds[index],
                                      userName: msgNames[index],
                                      avatarUrl: msgUrls[index],
                                    )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                          decoration: BoxDecoration(color: Color(0xFFFFEFEE)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage: AssetImage(
                                        'assets/images/profilepic.png'),
                                    //chats[index].sender
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        otherUserName,
                                        //chats[index].sender
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                      Text(
                                        eachMessage.message,
                                        //chats[index].message
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    timeago.format(eachMessage.time.toDate()),
                                    //${chats[index].time}'

                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  eachMessage.unread
                                      ? Container(
                                          width: 40.0,
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(20.0),
                                                  topRight:
                                                      Radius.circular(20.0),
                                                  bottomLeft:
                                                      Radius.circular(20.0),
                                                  bottomRight:
                                                      Radius.circular(20.0))),
                                          child: Padding(
                                            padding: EdgeInsets.all(3.0),
                                            child: Text(
                                              'New',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          : Container(
              child: Center(
                child: Text('You didn\'t chat with someone yet'),
              ),
            ),
    ));
  }

  retrieveMessageList() async {
    print('Current name and id:$currentName($currentId)');
    QuerySnapshot el = await Firestore.instance
        .collection('ChatRoom')
        .where("users", arrayContains: '$currentName($currentId)')
        .getDocuments();
    for (DocumentSnapshot element in el.documents) {
      //List<dynamic> idString = element.data.values.toList().elementAt(0);
      print(
          "First: ${element.data["users"][0]}\nSecond: ${element.data["users"][1]}");
      String personCombineId = element.data["users"][0];
      if (personCombineId.substring(0, personCombineId.lastIndexOf("(")) ==
          currentName) {
        personCombineId = element.data["users"][1];
      }
      otherUserId = personCombineId.substring(
          personCombineId.lastIndexOf("(") + 1,
          personCombineId.lastIndexOf(")"));
      print(otherUserId);
      msgIds.add(otherUserId);
      QuerySnapshot snapshot = await element.reference
          .collection("chats")
          .orderBy("time", descending: true)
          .getDocuments();
      messagess.add(Message.fromDocument(snapshot.documents.elementAt(0)));
      if (!lastMsg.containsKey(otherUserId)) {
        lastMsg.addAll({
          otherUserId: Message.fromDocument(snapshot.documents.elementAt(0))
        });
      }

      print("Shouldve added msg");
    }

    msgNames = List<String>(msgIds.length);
    msgUrls = List<String>(msgIds.length);
    QuerySnapshot usersSnapshot =
        await Firestore.instance.collection("Users").getDocuments();
    CollectionReference usersRef = Firestore.instance.collection("Users");
    msgNames = List<String>(msgIds.length);
    msgUrls = List<String>(msgIds.length);
    for (var i = 0; i < msgIds.length; i++) {
      Map<String, dynamic> ref = usersSnapshot.documents
          .firstWhere((element) => element.documentID == msgIds[i])
          .data;
      print("Iteration $i : id = ${msgIds[i]}");
      msgNames[i] = ref["name"];
      print("Name: ${msgNames[i]}");
      msgUrls[i] = ref["avatarUrl"];
    }
    setState(() {});
  }
}
