import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'User.dart';

// enum MediaType { image, video }

class Story {
  final String id;
  final String url;
  final String media;
  // final Duration duration;
  // final User user;

  const Story({
    @required this.id,
    @required this.url,
    @required this.media,
    // @required this.duration,
    // @required this.user,
  });

  factory Story.fromDocument(DocumentSnapshot doc) {
    return Story(
      id: doc.documentID,
      url: doc['url'],
      media: doc['media'],
    );
  }
}
