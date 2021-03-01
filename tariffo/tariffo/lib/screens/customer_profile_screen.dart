import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tariffo/User.dart';
import 'package:tariffo/data.dart';
import 'package:tariffo/messages_list.dart';
import 'package:tariffo/settingsPage.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String userID;
  const CustomerProfileScreen({
    Key key,
    this.userID,
  }) : super(key: key);
  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String userImage;
  User user;
  String address;

  @override
  void initState() {
    getData();
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * .10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                    ),
                    Text("Back"),
                  ],
                ),
              ),
            ),
          ),
          // profile setting and icon view
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .50,
            child: Stack(
              children: [
                Positioned(
                  child: Column(
                    children: [
                      Container(
                        height: 84,
                        width: 84,

                        //profilepic
                        child: GestureDetector(
                            onTap: () async {
                              await getImage();
//                          uploadPic(context);
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(userImage != null
                                  ? userImage
                                  : "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png"),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(user == null ? "" : user.name),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            address == null ? "" : address,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FlatButton(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            "Setting",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage(
                                      user: user,
                                    )),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  File _image;
  final picker = ImagePicker();
  Future<void> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      print("user id at upload Picture =${widget.userID}");
      print('image path ' + _image.path);
      StorageReference storageReference = FirebaseStorage.instance.ref();
      StorageUploadTask uploadTask = storageReference
          .child("Users Profile")
          .child("${widget.userID}")
          .putFile(_image);

      var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      String url = dowurl.toString();
      print('url is here $url');

      Map<String, dynamic> urlNull = {
        'avatarUrl': url,
      };
      DocumentReference prereference =
          Firestore.instance.collection('Users').document("${widget.userID}");

      await Firestore.instance.runTransaction((transaction) async {
        await transaction.update(prereference, urlNull).whenComplete(() {});
      });
    }
  }

  void getData() {
    Firestore.instance
        .collection("Users")
        .document("${widget.userID}")
        .snapshots()
        .listen((event) {
      setState(() {
        user = User.fromDocument(event);
        userImage = event.data['avatarUrl'];
      });
    });
  }

  getLocation() {
    try {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .asStream()
          .listen((event) {
        final coordinates = new Coordinates(event.latitude, event.longitude);

        Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .asStream()
            .listen((event2) {
          setState(() {
            address = event2.first.addressLine;
          });
        });
      });
    } catch (e) {
      if (e is PermissionDeniedException) {
        print(e);
      }
    }
  }
}
