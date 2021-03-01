import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'UserProfiles.dart';
import 'viewProfiles.dart';

class FavoriteProviders extends StatefulWidget {
  @override
  _FavoriteProvidersState createState() => _FavoriteProvidersState();
}

class _FavoriteProvidersState extends State<FavoriteProviders> {
  String currentUserID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Favorites",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              currentUserID = snapshot.data.uid;
              return FutureBuilder<QuerySnapshot>(
                future: Firestore.instance
                    .collection("Users")
                    .document(snapshot.data.uid)
                    .collection("favorites")
                    .getDocuments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<String> favIds = List<String>();
                    snapshot.data.documents.forEach((element) {
                      favIds.add(element.data["id"]);
                    });
                    return ListView.builder(
                      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                      itemCount: favIds.length,
                      itemBuilder: (BuildContext context, int index) {
                        String serviveProvideId = '${favIds[index]}';
                        return FutureBuilder(
                            future: Firestore.instance
                                .collection('Users')
                                .document(serviveProvideId)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snaps) {
                              String avatarUrl = snaps.data['avatarUrl'];
                              String address = snaps.data['address'];

                              print("avatarUrl       \n $avatarUrl");

                              return GestureDetector(
                                onTap: () async {
                                  String categoryName = (await snaps
                                          .data.reference
                                          .collection("BusinessAccount")
                                          .document("detail")
                                          .get())
                                      .data["category"];
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (_) => StoryProfiles(
                                              UserProfiles(
                                                  serviveProvideId,
                                                  snaps.data['name'],
                                                  avatarUrl,
                                                  address,
                                                  categoryName),
                                              currentUserID)));
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          40.0, 5.0, 20.0, 5.0),
                                      height: 170.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            100.0, 20.0, 20.0, 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Container(
                                                  width: 120.0,
                                                  child: Text(
                                                    snaps.data['name'],
                                                    // activity.name,
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Container(
                                                  width: 120.0,
                                                  child: Text(
                                                    snaps.data['address'],
                                                    // activity.name,
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Container(
                                                    child:
                                                        _buildRatingStars(3))),
                                            Expanded(
                                                child: FlatButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        snapshot.data.documents
                                                            .forEach((element) {
                                                          if (element
                                                                  .data["id"] ==
                                                              favIds[index]) {
                                                            element.reference
                                                                .delete();
                                                          }
                                                        });
                                                      });
                                                    },
                                                    color: Colors.grey,
                                                    child: Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20.0,
                                      top: 15.0,
                                      bottom: 15.0,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Image(
                                          width: 110.0,
                                          image: (avatarUrl != 'default')
                                              ? NetworkImage(
                                                  snaps.data['avatarUrl']
                                                  //  activity.imageUrl,

                                                  )
                                              : NetworkImage(
                                                  "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  }
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
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
