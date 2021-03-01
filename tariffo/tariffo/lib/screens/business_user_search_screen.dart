import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/UserProfiles.dart';
import 'package:tariffo/viewProfiles.dart';

class BusinessUserSearchScreen extends StatefulWidget {
  final String currentUserID;
  BusinessUserSearchScreen(this.currentUserID);

  BusinessUserSearchState createState() => BusinessUserSearchState();
}

class BusinessUserSearchState extends State<BusinessUserSearchScreen> {
  var categorySplit;
  TextEditingController searchController = TextEditingController();

  String serviveProvideId;

  Text _buildRatingStars(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐ ';
    }
    stars.trim();
    return Text(stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Business User"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(hintText: "Enter username"),
              controller: searchController,
              onChanged: (str) {
                setState(() {});
              },
            ),
          ),
          searchController.text == ""
              ? getAllUsersBuilder()
              : getSpecificUserBuilder()
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot> getSpecificUserBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Users')
            .where('userRole', isEqualTo: 'Business')
            .where('name', isEqualTo: searchController.text)
            .snapshots(),
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
                  return getUsersCategoryBuilder(snapshot, index);
                },
              ),
            );
          }
        });
  }

  FutureBuilder<QuerySnapshot> getAllUsersBuilder() {
    return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance
            .collection('Users')
            .where('userRole', isEqualTo: 'Business')
            .getDocuments(),
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
                  return getUsersCategoryBuilder(snapshot, index);
                },
              ),
            );
          }
        });
  }

  FutureBuilder<DocumentSnapshot> getUsersCategoryBuilder(
      AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return FutureBuilder(
        future:
            getUsersCategory('${snapshot.data.documents[index].documentID}'),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snaps) {
          if (!snaps.hasData) {
            return Container();
          } else {
            return getUserCategoryDetailsBuilder(snapshot, index, snaps);
          }
          // print("avatarUrl       \n $avatarUrl");
        });
  }

  FutureBuilder<DocumentSnapshot> getUserCategoryDetailsBuilder(
      AsyncSnapshot<QuerySnapshot> snapshot,
      int index,
      AsyncSnapshot<DocumentSnapshot> snaps) {
    String category = snaps.data.data['category'];
    return FutureBuilder(
        future: getUserCategoryDetails(
            snapshot.data.documents[index].documentID, category),
        builder: (BuildContext context, AsyncSnapshot snaps2) {
          if (!snaps2.hasData) {
            return Container();
          } else {
            return noLocationUsers(
                snapshot,
                snaps,
                index,
                snaps2.data['openTime'],
                snaps2.data['closeTime'],
                snaps2.data['id']);
          }
          // print("avatarUrl       \n $avatarUrl");
        });
  }

  Future<DocumentSnapshot> getUsersCategory(String data) async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('Users')
        .document(data)
        .collection('BusinessAccount')
        .document('detail')
        .get();

    return snapshot;
  }

  Future<DocumentSnapshot> getUserCategoryDetails(
      String id, String collection) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection(collection).document(id).get();
    return snapshot;
  }

  Widget noLocationUsers(
      AsyncSnapshot<QuerySnapshot> snapshot,
      AsyncSnapshot snaps,
      int index,
      String startTime,
      String closeTime,
      String id) {
    return GestureDetector(
      onTap: () {
        print(id);
        print(widget.currentUserID);
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (_) => StoryProfiles(
                    UserProfiles(
                        '$id',
                        snapshot.data.documents[index]['name'],
                        snapshot.data.documents[index]['avatarUrl'],
                        snapshot.data.documents[index]['address'],
                        snaps.data['category'] == null
                            ? ""
                            : snaps.data['category']),
                    widget.currentUserID)));
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
                          snapshot.data.documents[index]['name'],
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
                          snapshot.data.documents[index]['address'],
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
                    snaps.data['category'] == null
                        ? ""
                        : snaps.data['category'],
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
                image: (snapshot.data.documents[index]['avatarUrl'] ==
                        'default')
                    ? NetworkImage(
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"

                        //  activity.imageUrl,

                        )
                    : NetworkImage(snapshot.data.documents[index]['avatarUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tariffo/User.dart';
import 'package:tariffo/blocs/business_user_search_bloc/business_user_search_bloc.dart';

class BusinessUserSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessUserSearchBloc(),
      child: BusinessUserSearchBody(),
    );
  }
}

class BusinessUserSearchBody extends StatefulWidget {
  @override
  _BusinessUserSearchBodyState createState() => _BusinessUserSearchBodyState();
}

class _BusinessUserSearchBodyState extends State<BusinessUserSearchBody> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Business User'),
      ),
      body: Column(
        children: [
          textField(),
          BlocListener<BusinessUserSearchBloc, BusinessUserSearchState>(
            listener: (context, state) {},
            child: BlocBuilder<BusinessUserSearchBloc, BusinessUserSearchState>(
              builder: (context, state) {
                if (state is BusinessUserSearchInitial) {
                  return Container();
                } else if (state is BusinessUserSearchLoadingState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ShowAllUserState) {
                  return _showAllUsersBuilder(state.users,
                      state.usersCategories, state.getCategoriesDetails);
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _blocStateManagment() {
    return BlocListener<BusinessUserSearchBloc, BusinessUserSearchState>(
      listener: (context, state) {},
      child: BlocBuilder<BusinessUserSearchBloc, BusinessUserSearchState>(
        builder: (context, state) {
          if (state is BusinessUserSearchInitial) {
            return Container();
          } else if (state is BusinessUserSearchLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ShowAllUserState) {
            return _showAllUsersBuilder(
                state.users, state.usersCategories, state.getCategoriesDetails);
          }
          return Container();
        },
      ),
    );
  }

  Widget _showAllUsersBuilder(List<User> users, List<String> usersCategories,
      List<Map> getCategoriesDetails) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        return _userUI(
            users[index], usersCategories[index], getCategoriesDetails[index]);
      },
    );
  }

  Widget textField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        onChanged: (str) {},
        onEditingComplete: () {
          print('search event');
          BlocProvider.of<BusinessUserSearchBloc>(context)
              .add(SearchUserEvent(query: _searchController.text));
        },
        controller: _searchController,
      ),
    );
  }

  Widget _userUI(User user, String usersCategori, Map categoriesDetail) {
    return Container(
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
                    user.name,
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
            user.adress == null
                ? Container()
                : Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        width: 120.0,
                        child: Text(
                          user.adress,
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
              usersCategori,
              // activity.type,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            // _buildRatingStars(3),
            categoriesDetail == null ? Container() : SizedBox(height: 10.0),
            Row(
              children: <Widget>[
                categoriesDetail == null
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(5.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoriesDetail['openTime'].toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                categoriesDetail == null ? Container() : SizedBox(width: 10.0),
                categoriesDetail == null
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(5.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoriesDetail['closeTime'].toString(),
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
    );
  }
}
*/
