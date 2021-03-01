import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:path/path.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tariffo/LoginScreen.dart';
import 'package:tariffo/chatScreen.dart';
import 'package:tariffo/settingsPage.dart';
import 'package:tariffo/story_model.dart';
import 'package:tariffo/viewProfile.dart';
import 'User.dart';
import 'provider_widget.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'fullscreenImage.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:path/path.dart';

class UserPage extends StatefulWidget {
  ScrollController scrollController;
  @override
  _UserProfile createState() => _UserProfile();
}

class _UserProfile extends State<UserPage> {
  bool isFileImage = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  File pickedFile;
  String userImage;
  String address;
  String userName;
  String facebookUrl;
  String instagramUrl;
  String tikTokUrl;
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController tiktokController = TextEditingController();

  String userId;
  User userr = User();
  Random randomGenerator = Random();

  QuerySnapshot querySnapshot;
  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = await FirebaseAuth.instance.currentUser();
    userId = user.uid;
    print("user id at init user =$userId");
    getSocialData();
    getData();
  }

  TextEditingController _userAdressController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    print("user id at upload Picture =$userId");
    print('image path ' + _image.path);
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask = storageReference
        .child("Users Profile")
        .child("$userId")
        .putFile(_image);

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    print('url is here $url');

    Map<String, dynamic> urlNull = {
      'avatarUrl': url,
    };
    DocumentReference prereference =
        Firestore.instance.collection('Users').document("$userId");

    await Firestore.instance.runTransaction((transaction) async {
      await transaction.update(prereference, urlNull);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 4.5 - 28 + 84,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: MediaQuery.of(context).size.height / 4.5 - 85,
                left: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _launchUrl(tikTokUrl, context);
                      },
                      child: Image.asset(
                        'assets/images/tiktok.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _launchUrl(instagramUrl, context);
                      },
                      child: Image.asset(
                        'assets/images/instagram.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _launchUrl(facebookUrl, context);
                      },
                      child: Image.asset(
                        'assets/images/facebook.png',
                        width: 50,
                        height: 50,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                left: 24,
                top: MediaQuery.of(context).size.height / 4.5 - 28,
                child: Container(
                    height: 84,
                    width: 84,

                    //profilepic

                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(userImage != 'default' &&
                              userImage != null
                          ? userImage
                          : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                    )),
              ),
              Positioned(
                right: 24,
                top: MediaQuery.of(context).size.height / 4.5 + 16,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 32,
                      width: 100,
                      child: RaisedButton(
                          onPressed: () async {
                            await Alert(
                              context: context,
                              title: "",
                              desc: "Upload Image or Video to My Story",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Image",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => addPicture(uploadTypes.STORY,
                                      uploadTypes.IMAGE, context),
                                  width: 120,
                                ),
                                DialogButton(
                                  child: Text(
                                    "Video",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => addPicture(uploadTypes.STORY,
                                      uploadTypes.VIDEO, context),
                                  width: 120,
                                ),
                              ],
                            ).show();
                          },
                          color: Colors.black,
                          textColor: Colors.white,
                          child: Text(
                            "Add story",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () async {
                        DocumentSnapshot snapshot = await Firestore.instance
                            .collection('Users')
                            .document(userId)
                            .get();
                        User user = User.fromDocument(snapshot);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    user: user,
                                  )),
                        );
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn.clipart.email/bc95343ba501fa64026b6be15c5a2deb_free-settings-cliparts-download-free-clip-art-free-clip-art-on-_300-300.png"),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(children: [
          SizedBox(
            width: 30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /* FutureBuilder(future: Provider.of(context).auth.getCurrentUser(),
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            return Text("${snapshot.data.displayName}",);

                          }else {
                            return CircularProgressIndicator();
                          }
                        },
                        )*/
                  Text("$userName",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      )),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        address == "default" ? "No Address yet" : "$address",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      )),

                  /* Text("Centru Vechi , Targoviste",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            )),*/
                  ButtonTheme(
                      minWidth: 40.0,
                      height: 20.0,
                      buttonColor: Colors.white12,
                      child: OutlineButton(
                          child: Text("Edit"),
                          onPressed: () {
                            instagramController.text = instagramUrl;
                            tiktokController.text = tikTokUrl;
                            facebookController.text = facebookUrl;
                            _userEditBottomSheet(context);
                          }),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    " Pricelist ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width - 30,
                    child: FutureBuilder<QuerySnapshot>(
                        future: Firestore.instance
                            .collection("Users")
                            .document("$userId")
                            .collection("Gallery")
                            .getDocuments(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => FullscreenImage(
                                              snapshot.data.documents[index]
                                                  .data["url"],
                                              snapshot.data.documents[index]
                                                  .documentID,
                                              userId,
                                              userId),
                                        )),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 8, bottom: 8, right: 12),
                                      width: 80,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["url"]),
                                              fit: BoxFit.cover),
                                          color: Colors.transparent,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 2,
                                                spreadRadius: 1)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                    ),
                                  );
                                });
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Reviews",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width - 30,
                    child: FutureBuilder<QuerySnapshot>(
                        future: Firestore.instance
                            .collection("Users")
                            .document(userId)
                            .collection("BusinessAccount")
                            .document("detail")
                            .collection("reviews")
                            .getDocuments(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 200,
                                    margin: EdgeInsets.only(
                                        top: 8, bottom: 8, right: 12),
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          spreadRadius: 1)
                                    ], borderRadius: BorderRadius.circular(4)),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot.data.documents[index]
                                                      .data["avatarUrl"]),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                                snapshot.data.documents[index]
                                                    .data["name"],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                        _buildRatingStars(snapshot.data
                                            .documents[index].data["rating"]),
                                        Text(
                                            snapshot.data.documents[index]
                                                .data["text"],
                                            overflow: TextOverflow.ellipsis,
                                            textScaleFactor: 1.1)
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  )
                ],
              ),
            ],
          ),
        ]),
        Expanded(
            flex: 1,
            child: Container(
              height: 50,
              child: RaisedButton(
                color: Colors.blue,
                child: Center(
                  child: Text("Add photo to the pricelist",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
                /*onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (_) => LoginScreen()));
//                  Navigator.of(context).pushAndRemoveUntil(
//                      new MaterialPageRoute(
//                          builder: (context) => new LoginScreen()),
//                      (route) => false);
                  }*/
                onPressed: (() => addPicture(
                    uploadTypes.GALLERY, uploadTypes.IMAGE, context)),
              ),
            ))
      ],
    );
  }

  void _userEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * .80,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Update Profile"),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.cancel),
                          color: Colors.orange,
                          iconSize: 25,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: TextField(
                            controller: _userAdressController,
                            decoration: InputDecoration(
                              helperText: "Adress",
                            ),
                          ),
                        )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            child: Text('Save'),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () async {
                              String address = _userAdressController.text;
                              Map<String, dynamic> data = {
                                'address': address,
                              };
                              DocumentReference reference = Firestore.instance
                                  .collection('Users')
                                  .document("$userId");

                              Firestore.instance
                                  .runTransaction((transaction) async {
                                transaction.update(reference, data);
                              });

                              //                            final uid =
                              //                                await Provider.of(context).auth.getCurrentUID();
                              //                            await Provider.of(context)
                              //                                .db
                              //                                .collection('Users')
                              //                                .document('${user.uid}')
                              //                                .setData(userr.toJson());
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/tiktok.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextField(
                              controller: tiktokController,
                              decoration: InputDecoration(
                                  hintText: "Paste your link here"),
                              onChanged: (str) {
                                Firestore.instance
                                    .collection('Users')
                                    .document('$userId')
                                    .collection('Social')
                                    .document('detail')
                                    .setData({"tiktok": str}, merge: true);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/instagram.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextField(
                              controller: instagramController,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                  hintText: "Paste your link here"),
                              onChanged: (str) {
                                Firestore.instance
                                    .collection('Users')
                                    .document('$userId')
                                    .collection('Social')
                                    .document('detail')
                                    .setData({"instagram": str}, merge: true);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/facebook.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextField(
                              controller: facebookController,
                              decoration: InputDecoration(
                                  hintText: "Paste your link here"),
                              onChanged: (str) {
                                Firestore.instance
                                    .collection('Users')
                                    .document('$userId')
                                    .collection('Social')
                                    .document('detail')
                                    .setData({"facebook": str}, merge: true);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () {
                          getImage();
                        },
                        padding: EdgeInsets.all(10.0),
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text("Add profile picture"))
                  ],
                ),
              ),
            ),
          );
        });
  }

  void addPicture(uploadTypes type, uploadTypes types, context) async {
    CollectionReference galleryReference;
    try {
      galleryReference = Firestore.instance
          .collection("Users")
          .document("$userId")
          .collection(type == uploadTypes.GALLERY ? "Gallery" : "Story");
    } catch (e) {
      print(
          "Gallery/story collection can't be accessed or instantiated\n${e.toString()}");
      throw (e);
    }
    StorageReference storageFolderReference;
    try {
      storageFolderReference = FirebaseStorage.instance
          .ref()
          .child(type == uploadTypes.GALLERY ? "Galleries" : "Stories")
          .child("$userId");
    } catch (e) {
      print(
          "Gallery/story storage reference can't be accessed or instantiated\n${e.toString()}");
      throw (e);
    }
    final pickedFile = types == uploadTypes.IMAGE
        ? await picker.getImage(source: ImageSource.gallery)
        : await picker.getVideo(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    DocumentReference docRef =
        await galleryReference.add({"url": "", "media": ""});
    StorageReference imgRef =
        storageFolderReference.child("image_${docRef.documentID}");
    StorageTaskSnapshot snapshot = await imgRef
        .putFile(
            _image,
            types == uploadTypes.IMAGE
                ? StorageMetadata(contentType: 'image/png')
                : StorageMetadata(contentType: 'video/mp4'))
        .onComplete;
    snapshot.ref.getDownloadURL().then((value) {
      galleryReference.document("${docRef.documentID}").setData({
        "url": value.toString(),
        "media": types == uploadTypes.IMAGE ? "image" : "video"
      });
      setState(() {});
    });
    //while()
  }

  createChatroomAndStartConversation(String userName) {
    List<String> users = [
      userName,
    ];
    // authentication.createChatRoom()
  }

  void getData() {
    print("get data user id = $userId");
    Firestore.instance
        .collection("Users")
        .document("$userId")
        .snapshots()
        .listen((event) {
      setState(() {
        if (event.data == null) {
          print('bye faheem');
        }
        userImage = event.data['avatarUrl'];
        address = event.data['address'];
        userName = event.data['name'];
        print("$userImage  \n\n    $address   \n\n $userName");
      });
    });
  }

  void getSocialData() {
    DocumentReference reference = Firestore.instance
        .collection('Users')
        .document('$userId')
        .collection('Social')
        .document('detail');
    print(reference.path);
    reference.snapshots().listen((event) {
      setState(() {
        facebookUrl = event.data == null ? null : event.data['facebook'];
        instagramUrl = event.data == null ? null : event.data['instagram'];
        tikTokUrl = event.data == null ? null : event.data['tiktok'];
      });
    });
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      await Alert(
        context: context,
        type: AlertType.warning,
        title: "Social Link error",
        desc: "You have not provided social link",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
        ],
      ).show();
    } else {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        await Alert(
          context: context,
          type: AlertType.warning,
          title: "Social Link error",
          desc: "Cannot Launch Url",
          buttons: [
            DialogButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              color: Color.fromRGBO(0, 179, 134, 1.0),
            ),
          ],
        ).show();
      }
    }
  }
}

enum uploadTypes {
  GALLERY,
  STORY,
  VIDEO,
  IMAGE,
}
Text _buildRatingStars(int rating) {
  String stars = '';
  for (int i = 0; i < rating; i++) {
    stars += '⭐ ';
  }
  stars.trim();
  return Text(stars);
}
