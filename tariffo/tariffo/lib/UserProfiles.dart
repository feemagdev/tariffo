import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tariffo/chatScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fullscreenImage.dart';

class UserProfiles extends StatefulWidget {
  ScrollController scrollController;
  String serviceProviderId;
  String userName;
  String avatarUrl;
  String address;
  String categoryName;
  bool business;

  UserProfiles(String serviveProvideId, String userNmae, String avatarUrl,
      String address, String categoryName) {
    this.serviceProviderId = serviveProvideId;
    this.userName = userNmae;
    this.avatarUrl = avatarUrl;
    this.address = address;
    this.categoryName = categoryName;
  }

  void addController(ScrollController sc) {}

  @override
  _UserProfilesState createState() => _UserProfilesState();
}

class _UserProfilesState extends State<UserProfiles> {
  bool _isFavorite = false;
  String facebookUrl;
  String instagramUrl;
  String tikTokUrl;
  String myId;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //
  //   FirebaseAuth.instance.currentUser().then((value) {
  //
  //     myId=value.uid;
  //   });
  // }
  @override
  void initState() {
    super.initState();
    getSocialData();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((value) {
      myId = value.uid;
      Firestore.instance
          .collection("Users")
          .document(myId)
          .collection("favorites")
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot doc in value.documents) {
          if (doc.data["id"] == widget.serviceProviderId) {
            setState(() {
              _isFavorite = true;
            });
          }
        }
      });
    });
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
                /* Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 4.5,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ), */
                Positioned(
                  left: 24,
                  top: MediaQuery.of(context).size.height / 4.5 - 28,
                  child: Container(
                    height: 84,
                    width: 84,

                    //profilepic
                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(widget.avatarUrl != null
                          ? widget.avatarUrl
                          : "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png"),
                    ),
                  ),
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
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        serviceProviderId:
                                            widget.serviceProviderId,
                                        userName: widget.userName,
                                        avatarUrl: widget.avatarUrl,
                                      )));
                            },
                            color: Colors.black,
                            textColor: Colors.white,
                            child: Text(
                              "Message",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(
                        child: IconButton(
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              /* String myId =
                                  (await FirebaseAuth.instance.currentUser())
                                      .uid;
                              QuerySnapshot snapshot = await Firestore.instance
                                  .collection("Users")
                                  .document(myId)
                                  .collection("favorites")
                                  .getDocuments();
                              for (DocumentSnapshot snpsht
                                  in snapshot.documents) {
                                if (snpsht.data["id"] ==
                                    widget.serviceProviderId) {
                                  return;
                                }
                              } */
                              if (_isFavorite) {
                                //remove from database
                                QuerySnapshot snapshot = await Firestore
                                    .instance
                                    .collection("Users")
                                    .document(myId)
                                    .collection("favorites")
                                    .getDocuments();
                                for (DocumentSnapshot snpsht
                                    in snapshot.documents) {
                                  if (snpsht.data["id"] ==
                                      widget.serviceProviderId) {
                                    snpsht.reference.delete();
                                  }
                                  setState(() {
                                    _isFavorite = false;
                                  });
                                }
                              } else {
                                Firestore.instance
                                    .collection("Users")
                                    .document(myId)
                                    .collection("favorites")
                                    .add({"id": widget.serviceProviderId});
                                setState(() {
                                  _isFavorite = true;
                                });
                              }
                            }),
                      ),
                      
                    
                    ],
                  ),
                ),
                Positioned(
                    left: 24,
                    top: MediaQuery.of(context).size.height / 3.3,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          
                          Text(widget.userName,
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
                                widget.address == "default"
                                    ? "No Address yet"
                                    : "${widget.address}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                "${widget.categoryName}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ))
                        ],
                      ),
                    ))
              ],
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${widget.userName}",
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
                  widget.address == "default"
                      ? "No Address yet"
                      : "${widget.address}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            Text("PriceList", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width - 30,
              child: FutureBuilder<QuerySnapshot>(
                  future: Firestore.instance
                      .collection("Users")
                      .document("${widget.serviceProviderId}")
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
                                        snapshot
                                            .data.documents[index].data["url"],
                                        snapshot
                                            .data.documents[index].documentID,
                                        widget.serviceProviderId,
                                        myId),
                                  )),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 8, bottom: 8, right: 12),
                                width: 80,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(snapshot
                                            .data.documents[index].data["url"]),
                                        fit: BoxFit.cover),
                                    color: Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          spreadRadius: 1)
                                    ],
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            );
                          });
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ),
            SizedBox(
              height: 30,
            ),
            FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection("Users")
                  .document(widget.serviceProviderId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.data["userRole"] == "Business") {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text("Reviews",style: TextStyle(fontWeight: FontWeight.bold),),
                            FlatButton(
                              onPressed: () {
                                _addReviewBottomSheet(context);
                              },
                              child: Text("Add review"),
                            )
                          ],
                        ),
                        //start
                        SizedBox(
                          height: 100,
                          child: FutureBuilder<QuerySnapshot>(
                              future: Firestore.instance
                                  .collection("Users")
                                  .document("${widget.serviceProviderId}")
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
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 2,
                                                    spreadRadius: 1)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data
                                                            .documents[index]
                                                            .data["avatarUrl"]),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(snapshot
                                                      .data
                                                      .documents[index]
                                                      .data["name"], style:TextStyle(fontWeight: FontWeight.bold))
                                                ],
                                              ),
                                              _buildRatingStars(snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["rating"]),
                                              Text(snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["text"],overflow: TextOverflow.ellipsis,textScaleFactor: 1.1)
                                            ],
                                          ),
                                        );
                                      });
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                        )
                        //end
                      ],
                    );
                  }
                }
                return Container();
              },
            )
          ],
        ),
      ],
    );
  }

  void _addReviewBottomSheet(BuildContext context) {
    String imageUrl;
    String name;
    TextEditingController reviewController = TextEditingController();
    int rating = 1;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (context, newState) => Container(
              height: MediaQuery.of(context).size.height * .60,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Add review"),
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
                            controller: reviewController,
                            decoration: InputDecoration(
                              helperText: "Review",
                            ),
                          ),
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(flex: 4, child: Text("Stars given: ")),
                        Expanded(
                            flex: 6,
                            child: DropdownButton<int>(
                                value: rating,
                                items: List<DropdownMenuItem<int>>.generate(
                                    5,
                                    (index) => DropdownMenuItem<int>(
                                          value: index + 1,
                                          child: _buildRatingStars(index + 1),
                                        )),
                                onChanged: (value) {
                                  newState(() => rating = value);
                                }))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            child: Text('Save'),
                            color: Colors.green,
                            textColor: Colors.white,
                            onPressed: () async {
                              print('muISSSSSSSSSSSSSS here $myId');
                              await Firestore.instance
                                  .collection("Users")
                                  .document(myId)
                                  .get()
                                  .then((value) {
                                imageUrl = value.data['avatarUrl'];
                                name = value.data['name'];
                              });

                              await Firestore.instance
                                  .collection("Users")
                                  .document(widget.serviceProviderId)
                                  .collection("BusinessAccount")
                                  .document("detail")
                                  .collection("reviews")
                                  .add({
                                "text": reviewController.text,
                                "rating": rating,
                                "avatarUrl": imageUrl,
                                "name": name
                              });

                              await Firestore.instance
                                  .collection("Users")
                                  .document(myId)
                                  .collection("Reviews")
                                  .add({
                                "text": reviewController.text,
                                "rating": rating,
                                "avatarUrl": imageUrl,
                                "name": name
                              });
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void getSocialData() {
    DocumentReference reference = Firestore.instance
        .collection('Users')
        .document('${widget.serviceProviderId}')
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
        desc: "User have not provided social link",
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

Text _buildRatingStars(int rating) {
  String stars = '';
  for (int i = 0; i < rating; i++) {
    stars += '⭐ ';
  }
  stars.trim();
  return Text(stars);
}
