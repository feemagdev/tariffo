import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tariffo/UserProfiles.dart';
import 'package:tariffo/viewProfiles.dart';

class TransportScreen extends StatefulWidget {
  final String serviceName;
  final List<String> location;

  TransportScreen(this.serviceName, this.location);

  TransportState createState() => TransportState();
}

class TransportState extends State<TransportScreen> {
  var categorySplit;
  String country;
  String countryCode;

  initState() {
    super.initState();
    if (widget.location.isNotEmpty) {
      countryCode = widget.location[1];
      country = widget.location[0];
    }
  }

  String serviveProvideId;

  Text _buildRatingStars(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐ ';
    }
    stars.trim();
    return Text(stars);
  }

  Widget build(BuildContext context) {
//    setState(() {
//      categorySplit='${widget.serviceName}'.split(' ');
//
//      print('Splt Category ${categorySplit[0]} And ${categorySplit[1]}');
//    });

    print('received String ${widget.serviceName}');

    return Scaffold(
      body: Column(
        children: [
          Stack(children: [
            Container(
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0.0, 2.0),
                    blurRadius: 6.0,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image(
                  image: NetworkImage(
                    'http://az756667.vo.msecnd.net/cache/b/1/d/c/d/6/b1dcd62c25b541176b2947063bea60e10bf357c0.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        iconSize: 30.0,
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(children: <Widget>[
                     
                      ])
                    ])),
            Positioned(
                left: 20.0,
                bottom: 20.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.serviceName,
                        //  widget.destination.city,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.locationArrow,
                            size: 15.0,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            // widget.destination.country,
                            "near you",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ])),
            Positioned(
              right: 20.0,
              bottom: 20.0,
              child: Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 25.0,
              ),
            ),
          ]),
          StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection(widget.serviceName).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                      //itemCount: widget.destination.activities.length,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        serviveProvideId =
                            '${snapshot.data.documents[index].data['id']}';

                        String startTime =
                            '${snapshot.data.documents[index].data['openTime']}';
                        String closeTime =
                            '${snapshot.data.documents[index].data['closeTime']}';

                        return FutureBuilder(
                            future: getUsers(
                                '${snapshot.data.documents[index].data['id']}'),
                            builder:
                                (BuildContext context, AsyncSnapshot snaps) {
                              // print("avatarUrl       \n $avatarUrl");

                              if (widget.location.isEmpty) {
                                if (snaps.hasData) {
                                  return noLocationUsers(snapshot, snaps, index,
                                      startTime, closeTime);
                                } else {
                                  return Container();
                                }
                              } else {
                                if (snaps.hasData) {
                                  if (snaps.data['country'] == country ||
                                      snaps.data['country'] == countryCode) {
                                    return noLocationUsers(snapshot, snaps,
                                        index, startTime, closeTime);
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              }
                            });
                      },
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  Future<DocumentSnapshot> getUsers(String data) {
    return Firestore.instance.collection('Users').document(data).get();
  }

  Widget noLocationUsers(AsyncSnapshot<QuerySnapshot> snapshot,
      AsyncSnapshot snaps, int index, String startTime, String closeTime) {
    return GestureDetector(
      onTap: () async {
        FirebaseUser currentLoggedInUser =
            await FirebaseAuth.instance.currentUser();

//                                  Navigator.push(context, new MaterialPageRoute(builder: (_)=>ViewUserPage()));
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (_) => StoryProfiles(
                    UserProfiles(
                        '${snapshot.data.documents[index].data['id']}',
                        snaps.data['name'],
                        snaps.data['avatarUrl'],
                        snaps.data['address'],
                        snapshot.data.documents[index].data['categoryName']),
                    currentLoggedInUser.uid)));
      },
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(40.0, 5.0, 20.0, 5.0),
            height: 170.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(100.0, 20.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        width: 120.0,
                        child: Text(
                          snaps.data['name'],
                          // activity.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        width: 120.0,
                        child: Text(
                          snaps.data['address'],
                          // activity.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    snapshot.data.documents[index].data['categoryName'],
                    // activity.type,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  _buildRatingStars(3),
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          startTime,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          closeTime,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.0,
            top: 15.0,
            bottom: 15.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                width: 110.0,
                image: (snaps.data['avatarUrl'] == 'default')
                    ? NetworkImage(
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"

                        //  activity.imageUrl,

                        )
                    : NetworkImage(snaps.data['avatarUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
