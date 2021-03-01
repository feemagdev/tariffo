import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter/cupertino.dart';

class ChatScreen extends StatefulWidget {
//  final User user;
//
//  ChatScreen({this.user});

  String serviceProviderId;
  String avatarUrl;
  String userName;

  ChatScreen({this.serviceProviderId, this.userName, this.avatarUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentUserId;
  String currentName;

  String onlineStatus;
  static List<Message> messages = [];
  Message eachMessage;
  CollectionReference messageColl = Firestore.instance.collection('ChatRoom');

  TextEditingController messageController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseAuth.instance.currentUser().then((value) {
      currentUserId = value.uid;
      Firestore.instance
          .collection('Users')
          .document('$currentUserId')
          .get()
          .then((value) {
        setState(() {
          currentName = value.data['name'];
          print("current Name $currentName");
          onlineStatus = value.data['status'];
          print('hello status here $onlineStatus');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
//    retrieveMessage();
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: widget.userName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  TextSpan(text: '\n'),
                  TextSpan(text: onlineStatus)
                ],
              ))),
      body: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: messageColl
                  .document('$currentName&${widget.userName}')
                  .collection("chats")
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
//                       eachMessage=messages[index];
                          bool isMe =
                              snapshot.data.documents[index].data['sender'] ==
                                  currentName;

                          return FutureBuilder(
                              future: Firestore.instance
                                  .collection('Users')
                                  .document(currentUserId)
                                  .get(),
                              builder:
                                  (BuildContext context, AsyncSnapshot snaps) {
                                if (!snaps.hasData) {
                                  return CircularProgressIndicator();
                                } else {
                                  String userAvatar;
                                  if (snaps.data['avatarUrl'] == null ||
                                      snaps.data['avatarUrl'] == 'default') {
                                    userAvatar =
                                        "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png";
                                  } else {
                                    userAvatar = snaps.data['avatarUrl'];
                                  }
                                  return isMe
                                      ? Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Container(
                                                  alignment: Alignment.topRight,
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5)
                                                    ],
                                                  ),
                                                  child: Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['message'],
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    timeago.format(snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['time']
                                                        .toDate()),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                          )
                                                        ]),
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              userAvatar),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Container(
                                                  alignment: Alignment.topLeft,
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5)
                                                    ],
                                                  ),
                                                  child: Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['message'],
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black54)),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                          )
                                                        ]),
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage:
                                                          NetworkImage(widget
                                                                      .avatarUrl !=
                                                                  'default'
                                                              ? widget.avatarUrl
                                                              : "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png"),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    timeago.format(snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['time']
                                                        .toDate()),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                }
                              });
                        }),
                  );
                }
              }),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: 70,
              color: Colors.white,
              child: Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue,
                    child: IconButton(
                      icon: Icon(Icons.photo),
                      iconSize: 25,
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        hintText: 'Enter message here'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue,
                    child: IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25,
                      color: Colors.white,
                      onPressed: () {
                        sendMessage();
                      },
                    ),
                  ),
                ),
              ]))
        ],
      ),
    );
  }

  void sendMessage() async {
    List<String> userMap = [
      '$currentName($currentUserId)',
      '${widget.userName}(${widget.serviceProviderId})'
    ];
    await messageColl.document('$currentName&${widget.userName}').setData(
        {"users": userMap, "chatRoomId": '$currentName&${widget.userName}'});

    messageColl
        .document('$currentName&${widget.userName}')
        .collection("chats")
        .document()
        .setData({
      'sender': "$currentName",
      'time': DateTime.now(),
      'message': messageController.text,
      'unread': true,
    });
    messageColl
        .document('${widget.userName}&$currentName')
        .collection("chats")
        .document()
        .setData({
      'sender': "$currentName",
      'time': DateTime.now(),
      'message': messageController.text,
      'unread': true,
    });
    messageController.text = '';
  }
//  Future retrieveMessage()  {
//
//
//
////    print('messages of  $currentName&${widget.userName}');
////    messageColl.document('$currentName&${widget.userName}').collection("chats").orderBy('time',descending: false).snapshots().listen((event) {
////      messages.clear();
////      event.documents.forEach((element) {
////        eachMessage=Message.fromDocument(element);
////        print('sender   '+element.data['sender']);
////
////        setState(() {
////          messages.add(eachMessage);
////        });
////      });
////    });
//  }

}
