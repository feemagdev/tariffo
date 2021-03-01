import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String userRole;
  String avatarUrl;
  String adress;
  String country;
  User(
      {this.uid,
      this.name,
      this.email,
      this.userRole,
      this.adress,
      this.avatarUrl,
      this.country});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        uid: doc.documentID,
        name: doc['name'],
        email: doc['email'],
        userRole: doc['userRole'],
        adress: doc['adress'],
        country: doc['country'],
        avatarUrl: doc['avatarUrl']);
  }
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'userRole': userRole,
        'adress': adress,
        'country': country,
        'avatarUrl': avatarUrl
      };
}
