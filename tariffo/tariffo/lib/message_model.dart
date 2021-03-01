import 'package:cloud_firestore/cloud_firestore.dart';

import 'User.dart';
import 'auth.dart';

class Message {
  final String sender;
  final Timestamp
      time; // Would usually be type DateTime or Firebase Timestamp in production apps
  final String message;

  final bool unread;

  Message({
    this.sender,
    this.time,
    this.message,
    this.unread,
  });
  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      sender: doc['sender'],
      message: doc['message'],
      time: doc['time'],
      unread: doc['unread'],
    );
  }
}
