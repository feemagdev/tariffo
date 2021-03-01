import 'dart:math';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tariffo/CustomerPosts.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:tariffo/Screens/business_user_search_screen.dart';
import 'package:tariffo/SubscriptionOptions.dart';
import 'package:tariffo/UserProfiles.dart';
import 'package:tariffo/categoriesScroller.dart';
import 'package:tariffo/favoriteProviders.dart';
import 'package:tariffo/messages_list.dart';
import 'package:tariffo/settingsPage.dart';
import 'package:tariffo/utils/users_handling.dart';
import 'package:tariffo/viewProfile.dart';
import 'package:tariffo/viewProfiles.dart';
import 'AppBarW.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
    );
  }
}

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);
}

class Homepage extends StatefulWidget {
  ScrollController scrollController;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  String qrResult = "Not yet Scanned";
  String country;
  bool check = false;
  int checkIndex = 0;
  bool loadingQrUser = false;
  final SearchBarController<Post> _searchBarController = SearchBarController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _currentIndex = 0;
  PageController _pageController;

  void _onRefresh() async {
    // monitor network fetch
    checkIndex = 0;
    await getServiceProviderProfile();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void _onLoading() async {
    // monitor network fetch
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isReplay = false;

  var now;
  var date;
  bool subscriptionExpired = false;
  var diff;
  String userId;

  List<DocumentSnapshot> usersList = [];
  bool loadingUsers = true;
  int perPageLimit = 5;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = new ScrollController();
  String serviveProvideId;
  List<String> categoryList = [];
  Future<List<Post>> _getALlPosts(String text) async {
    await Future.delayed(Duration(seconds: text.length == 4 ? 10 : 1));
    if (isReplay) return [Post("Replaying !", "Replaying body")];
    if (text.length == 2) throw Error();
    if (text.length == 6) return [];
    List<Post> posts = [];

    var random = new Random();
    for (int i = 0; i < 10; i++) {
      posts
          .add(Post("$text $i", "body random number : ${random.nextInt(100)}"));
    }
    return posts;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();

    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        userId = value.uid;
        // serviveProvideId=value.uid
      });
    }).whenComplete(() {
      Firestore.instance
          .collection("SuperUser")
          .document('$userId')
          .get()
          .then((value) {
        if (value.exists) {
          subscriptionExpired = value.data['expired'];
          if (subscriptionExpired == true) {
            showSubscriptionDialogue();
          } else {
            checkSubscription();
          }
        }
      });
    });

    getServiceProviderProfile();

    WidgetsBinding.instance.addObserver(this);

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double scrollPixels = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.9;
      if (maxScroll - scrollPixels <= delta) {
        //  getFurtherProfile();
        // print('get furthhhher profile called');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            _homePage(),
            FavoriteProviders(),
            CustomerPosts(),
            MessageList(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _homePage() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return loadingUsers == true
        ? Container(
            height: height,
            width: width,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
                title: Text('Tariffo',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SignPainter',
                        fontSize: 45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                  ),
                  IconButton(
                    icon: Icon(Icons.center_focus_weak),
                    onPressed: () async {
                      try {
                        String scaning = await BarcodeScanner.scan();
                        if (scaning.isNotEmpty) {
                          setState(() {
                            loadingQrUser = true;
                          });
                          DocumentSnapshot snapshot = await Firestore.instance
                              .collection('Users')
                              .document(scaning)
                              .get();
                          if (snapshot.exists) {
                            DocumentSnapshot snapshot2 = await Firestore
                                .instance
                                .collection('Users')
                                .document(snapshot.documentID)
                                .collection('BusinessAccount')
                                .document('detail')
                                .get();
                            navigateToUserProfilePage(
                                snapshot, context, userId, snapshot2);
                          } else {
                            setState(() {
                              loadingQrUser = false;
                            });
                          }
                        }
                      } catch (exception) {
                        print("format exception");
                      }
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.perm_identity,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        FirebaseUser user =
                            await FirebaseAuth.instance.currentUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserHandling(
                                    uid: user.uid,
                                  )),
                        );
                      }),
                ],
                automaticallyImplyLeading: false),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          readOnly: true,
                          decoration:
                              InputDecoration(hintText: "Search Business"),
                          onTap: () async {
                            FirebaseUser user =
                                await FirebaseAuth.instance.currentUser();

                            navigateToSearchPage(user.uid);
                          },
                        ),
                      ),
                    ),
                    Column(children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 100.0, left: 20.0),
                        child: Text(
                          "Explore Popular Categories",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                              fontSize: 18),
                        ),
                      ),
                      // CarouselDemoState(),

                      // subscriptionExpired == true ? Container(
                      //   width: MediaQuery
                      //       .of(context)
                      //       .size
                      //       .width * 0.98,
                      //   height: 40.0,
                      //   color: Colors.redAccent,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //
                      //       Row(
                      //         children: [
                      //           IconButton(icon: Icon(
                      //             Icons.clear, size: 24.0, color: Colors.white,),
                      //               onPressed: () {}),
                      //           Text("Your Subscription Expired .",
                      //             style: TextStyle(color: Colors.white,
                      //                 fontWeight: FontWeight.bold,
                      //                 fontSize: 17.0),),
                      //         ],
                      //       ),
                      //       IconButton(icon: Icon(Icons.arrow_forward_ios,
                      //         size: 24.0, color: Colors.white,),
                      //           onPressed: () {}),
                      //
                      //     ],
                      //   ),
                      // ) : Container(),

                      CategoriesScroller(),
                      TopText(),
                      //Appbar()
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 250.0,
                        child: SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: true,
                          enablePullUp: true,
                          header: WaterDropHeader(),
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: ListView.builder(
                            itemCount: usersList.length,
                            itemBuilder: (BuildContext context, int index) {
                              serviveProvideId = usersList[index].data['user'];

                              return usersList.length == 0
                                  ? Container()
                                  : FutureBuilder(
                                      future: Firestore.instance
                                          .collection('Users')
                                          .document('$serviveProvideId')
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snaps) {
                                        if (!snaps.hasData) {
                                          return Container();
                                        } else {
                                          if (snaps.data.data['country'] ==
                                              country) {
                                            String id = snaps.data.documentID;
                                            return FutureBuilder(
                                              future: Firestore.instance
                                                  .collection(
                                                      'Users/$id/BusinessAccount')
                                                  .document('detail')
                                                  .get(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          DocumentSnapshot>
                                                      snapshot2) {
                                                if (!snapshot2.hasData) {
                                                  return Container();
                                                } else {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (_) => StoryProfiles(
                                                                  UserProfiles(
                                                                      '$id',
                                                                      snaps.data[
                                                                          'name'],
                                                                      snaps.data[
                                                                          'avatarUrl'],
                                                                      snaps.data[
                                                                          'address'],
                                                                      snapshot2
                                                                          .data
                                                                          .data['category']),
                                                                  userId)));
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      child: Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                            child: Image(
                                                              width: 110.0,
                                                              height: 160,
                                                              image: (snaps.data[
                                                                          'avatarUrl'] ==
                                                                      'default')
                                                                  ? NetworkImage(
                                                                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"

                                                                      //  activity.imageUrl,

                                                                      )
                                                                  : NetworkImage(
                                                                      snaps.data[
                                                                          'avatarUrl']),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .fromLTRB(
                                                                    5.0,
                                                                    5.0,
                                                                    5.0,
                                                                    5.0),
                                                            height: 170.0,
                                                            // width: double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          5.0,
                                                                          50.0,
                                                                          5.0,
                                                                          5.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          120.0,
                                                                      child:
                                                                          Text(
                                                                        snaps.data[
                                                                            'name'],
                                                                        // activity.name,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          120.0,
                                                                      child:
                                                                          Text(
                                                                        snaps.data[
                                                                            'address'],
                                                                        // activity.name,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    snapshot2
                                                                            .data
                                                                            .data[
                                                                        'category'],
                                                                    // activity.type,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }
                                      });
                            },
                          ),
                        ),
                      )
                    ]),

                    /* SearchBar<Post>(
                      searchBarPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      headerPadding: EdgeInsets.symmetric(horizontal: 10),
                      listPadding: EdgeInsets.symmetric(horizontal: 10),
                      onSearch: _getALlPosts,
                      searchBarController: _searchBarController,
                      placeHolder: Text(""),
                      cancellationWidget: Text("Cancel"),
                      emptyWidget: Text("empty"),
                      indexedScaledTileBuilder: (int index) =>
                          ScaledTile.count(1, index.isEven ? 2 : 1),
                      onCancelled: () {
                        print("Cancelled triggered");
                      },
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                      onItemFound: (Post post, int index) {
                        return Container(
                          color: Colors.lightBlue,
                          child: ListTile(
                            title: Text(post.title),
                            isThreeLine: true,
                            subtitle: Text(post.body),
                            onTap: () {
                              //  Navigator.of(context).push(
                              //    MaterialPageRoute(builder: (context) => Detail()));
                            },
                          ),
                        );
                      },
                    ), */
                  ],
                ),
              ),
            ),
          );
  }

  checkSubscription() async {
    await Firestore.instance
        .collection('SuperUser')
        .document('$userId')
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          subscriptionExpired = value.data['expired'];
          now = DateTime.now();
          date = DateTime.fromMillisecondsSinceEpoch(value.data['expired_on']);
          diff = date.difference(now);

          // print('Difference issss $diff and subscriptionExpired ? $subscriptionExpired');
        });
        if (subscriptionExpired == true) {
          showSubscriptionDialogue();
        } else {
          if ((diff.inHours - (diff.inDays * 24)) <= 0 && diff.inDays < 0) {
            DocumentReference reference =
                Firestore.instance.collection('SuperUser').document('$userId');
            Firestore.instance.runTransaction((transaction) {
              return transaction.update(reference, {
                "expired": true,
                "plan": "",
                "notified": true,
              });
            });
          }
        }
      }
    });
  }

  void ShowSubscriptionDialogue() {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).primaryColor,
        transitionDuration: const Duration(microseconds: 200),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondAnimation) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.6,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.red,
              ),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 0.6 / 3 - 10,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.6 / 3 -
                                    10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                                // child: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: <Widget>[
                                //     Text(
                                //       'BASIC',
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '7 days',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '\$2.99',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     InkWell(
                                //       onTap:(){
                                //         Navigator.pop(context);
                                //
                                //         showBottomSheet('basic','299',context);
                                //       },
                                //       child: Container(
                                //         height:40.0,
                                //         width: 80.0,
                                //
                                //         decoration: BoxDecoration(
                                //           color: Theme.of(context)
                                //               .primaryColor,
                                //           borderRadius:
                                //           BorderRadius.circular(30.0),
                                //           border: Border.all(
                                //               width: 3.0,
                                //               color: Theme.of(context)
                                //                   .primaryColor),
                                //         ),
                                //         child: Center(
                                //           child: Text(
                                //             'Basic',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.bold,
                                //                 fontSize: 12.0,
                                //                 color: Colors.white),
                                //           ),
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                ),
                          ),
                          Container(
                            height: 40.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Basic',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 0.6 / 3 - 10,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.6 / 3 -
                                    10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                                // child: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: <Widget>[
                                //     Text(
                                //       'BASIC',
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '7 days',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '\$2.99',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     InkWell(
                                //       onTap:(){
                                //         Navigator.pop(context);
                                //
                                //         showBottomSheet('basic','299',context);
                                //       },
                                //       child: Container(
                                //         height:40.0,
                                //         width: 80.0,
                                //
                                //         decoration: BoxDecoration(
                                //           color: Theme.of(context)
                                //               .primaryColor,
                                //           borderRadius:
                                //           BorderRadius.circular(30.0),
                                //           border: Border.all(
                                //               width: 3.0,
                                //               color: Theme.of(context)
                                //                   .primaryColor),
                                //         ),
                                //         child: Center(
                                //           child: Text(
                                //             'Basic',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.bold,
                                //                 fontSize: 12.0,
                                //                 color: Colors.white),
                                //           ),
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                ),
                          ),
                          Container(
                            height: 40.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Basic',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 0.6 / 3 - 10,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.6 / 3 -
                                    10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                                // child: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: <Widget>[
                                //     Text(
                                //       'BASIC',
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '7 days',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     Text(
                                //       '\$2.99',
                                //       style: TextStyle(
                                //         fontSize: 12.0,
                                //       ),
                                //     ),
                                //     InkWell(
                                //       onTap:(){
                                //         Navigator.pop(context);
                                //
                                //         showBottomSheet('basic','299',context);
                                //       },
                                //       child: Container(
                                //         height:40.0,
                                //         width: 80.0,
                                //
                                //         decoration: BoxDecoration(
                                //           color: Theme.of(context)
                                //               .primaryColor,
                                //           borderRadius:
                                //           BorderRadius.circular(30.0),
                                //           border: Border.all(
                                //               width: 3.0,
                                //               color: Theme.of(context)
                                //                   .primaryColor),
                                //         ),
                                //         child: Center(
                                //           child: Text(
                                //             'Basic',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.bold,
                                //                 fontSize: 12.0,
                                //                 color: Colors.white),
                                //           ),
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                ),
                          ),
                          Container(
                            height: 40.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Basic',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void showSubscriptionDialogue() {
    // showGeneralDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     barrierColor: Theme.of(context).primaryColor,
    // transitionDuration: const Duration(microseconds: 200),
    // pageBuilder: (BuildContext context, Animation animation,
    // Animation secondAnimation) {
    //   return SizedBox(
    //     height: MediaQuery.of(context).size.height*0.6,
    //     width: MediaQuery.of(context).size.width*0.6,
    //     child: Container(
    //       height: MediaQuery.of(context).size.height*0.6,
    //       width: MediaQuery.of(context).size.width*0.6,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(30.0),
    //         color: Colors.red,
    //
    //       ),
    //
    //       child: Center(
    //         child: Container(
    //           height: MediaQuery.of(context).size.height*0.6,
    //           width: MediaQuery.of(context).size.width*0.6,
    //           child: Column(
    //             children: <Widget>[
    //
    //               Container(
    //                 height: MediaQuery.of(context).size.height*0.6/3-10,
    //                 width: MediaQuery.of(context).size.width*0.7,
    //                 child: Stack(
    //
    //                     alignment: Alignment.topRight,
    //                     children: [
    //                       Container(
    //                         width: MediaQuery.of(context).size.width*0.7,
    //                         height: MediaQuery.of(context).size.height*0.6/3-10,
    //
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 1.5,
    //                               color: Theme.of(context).primaryColor),
    //                         ),
    //                         child: Center(
    //                           // child: Column(
    //                           //   mainAxisAlignment: MainAxisAlignment.center,
    //                           //   children: <Widget>[
    //                           //     Text(
    //                           //       'BASIC',
    //                           //       style: TextStyle(
    //                           //         fontWeight: FontWeight.bold,
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '7 days',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '\$2.99',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     InkWell(
    //                           //       onTap:(){
    //                           //         Navigator.pop(context);
    //                           //
    //                           //         showBottomSheet('basic','299',context);
    //                           //       },
    //                           //       child: Container(
    //                           //         height:40.0,
    //                           //         width: 80.0,
    //                           //
    //                           //         decoration: BoxDecoration(
    //                           //           color: Theme.of(context)
    //                           //               .primaryColor,
    //                           //           borderRadius:
    //                           //           BorderRadius.circular(30.0),
    //                           //           border: Border.all(
    //                           //               width: 3.0,
    //                           //               color: Theme.of(context)
    //                           //                   .primaryColor),
    //                           //         ),
    //                           //         child: Center(
    //                           //           child: Text(
    //                           //             'Basic',
    //                           //             style: TextStyle(
    //                           //                 fontWeight: FontWeight.bold,
    //                           //                 fontSize: 12.0,
    //                           //                 color: Colors.white),
    //                           //           ),
    //                           //         ),
    //                           //       ),
    //                           //     )
    //                           //   ],
    //                           // ),
    //                         ),
    //                       ),
    //                       Container(
    //                         height:40.0,
    //                         width: 80.0,
    //
    //                         decoration: BoxDecoration(
    //                           color: Theme.of(context)
    //                               .primaryColor,
    //                           borderRadius:
    //                           BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 3.0,
    //                               color: Theme.of(context)
    //                                   .primaryColor),
    //                         ),
    //                         child: Center(
    //                           child: Text(
    //                             'Basic',
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 12.0,
    //                                 color: Colors.white),
    //                           ),
    //                         ),
    //                       ),
    //                     ]
    //
    //                 ),
    //               ),
    //
    //               SizedBox(height:30.0),
    //               Container(
    //                 height: MediaQuery.of(context).size.height*0.6/3-10,
    //                 width: MediaQuery.of(context).size.width*0.7,
    //                 child: Stack(
    //
    //                     alignment: Alignment.topRight,
    //                     children: [
    //                       Container(
    //                         width: MediaQuery.of(context).size.width*0.7,
    //                         height: MediaQuery.of(context).size.height*0.6/3-10,
    //
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 1.5,
    //                               color: Theme.of(context).primaryColor),
    //                         ),
    //                         child: Center(
    //                           // child: Column(
    //                           //   mainAxisAlignment: MainAxisAlignment.center,
    //                           //   children: <Widget>[
    //                           //     Text(
    //                           //       'BASIC',
    //                           //       style: TextStyle(
    //                           //         fontWeight: FontWeight.bold,
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '7 days',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '\$2.99',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     InkWell(
    //                           //       onTap:(){
    //                           //         Navigator.pop(context);
    //                           //
    //                           //         showBottomSheet('basic','299',context);
    //                           //       },
    //                           //       child: Container(
    //                           //         height:40.0,
    //                           //         width: 80.0,
    //                           //
    //                           //         decoration: BoxDecoration(
    //                           //           color: Theme.of(context)
    //                           //               .primaryColor,
    //                           //           borderRadius:
    //                           //           BorderRadius.circular(30.0),
    //                           //           border: Border.all(
    //                           //               width: 3.0,
    //                           //               color: Theme.of(context)
    //                           //                   .primaryColor),
    //                           //         ),
    //                           //         child: Center(
    //                           //           child: Text(
    //                           //             'Basic',
    //                           //             style: TextStyle(
    //                           //                 fontWeight: FontWeight.bold,
    //                           //                 fontSize: 12.0,
    //                           //                 color: Colors.white),
    //                           //           ),
    //                           //         ),
    //                           //       ),
    //                           //     )
    //                           //   ],
    //                           // ),
    //                         ),
    //                       ),
    //                       Container(
    //                         height:40.0,
    //                         width: 80.0,
    //
    //                         decoration: BoxDecoration(
    //                           color: Theme.of(context)
    //                               .primaryColor,
    //                           borderRadius:
    //                           BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 3.0,
    //                               color: Theme.of(context)
    //                                   .primaryColor),
    //                         ),
    //                         child: Center(
    //                           child: Text(
    //                             'Basic',
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 12.0,
    //                                 color: Colors.white),
    //                           ),
    //                         ),
    //                       ),
    //                     ]
    //
    //                 ),
    //               ),
    //               SizedBox(height:30.0),
    //               Container(
    //                 height: MediaQuery.of(context).size.height*0.6/3-10,
    //                 width: MediaQuery.of(context).size.width*0.7,
    //                 child: Stack(
    //
    //                     alignment: Alignment.topRight,
    //                     children: [
    //                       Container(
    //                         width: MediaQuery.of(context).size.width*0.7,
    //                         height: MediaQuery.of(context).size.height*0.6/3-10,
    //
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 1.5,
    //                               color: Theme.of(context).primaryColor),
    //                         ),
    //                         child: Center(
    //                           // child: Column(
    //                           //   mainAxisAlignment: MainAxisAlignment.center,
    //                           //   children: <Widget>[
    //                           //     Text(
    //                           //       'BASIC',
    //                           //       style: TextStyle(
    //                           //         fontWeight: FontWeight.bold,
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '7 days',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     Text(
    //                           //       '\$2.99',
    //                           //       style: TextStyle(
    //                           //         fontSize: 12.0,
    //                           //       ),
    //                           //     ),
    //                           //     InkWell(
    //                           //       onTap:(){
    //                           //         Navigator.pop(context);
    //                           //
    //                           //         showBottomSheet('basic','299',context);
    //                           //       },
    //                           //       child: Container(
    //                           //         height:40.0,
    //                           //         width: 80.0,
    //                           //
    //                           //         decoration: BoxDecoration(
    //                           //           color: Theme.of(context)
    //                           //               .primaryColor,
    //                           //           borderRadius:
    //                           //           BorderRadius.circular(30.0),
    //                           //           border: Border.all(
    //                           //               width: 3.0,
    //                           //               color: Theme.of(context)
    //                           //                   .primaryColor),
    //                           //         ),
    //                           //         child: Center(
    //                           //           child: Text(
    //                           //             'Basic',
    //                           //             style: TextStyle(
    //                           //                 fontWeight: FontWeight.bold,
    //                           //                 fontSize: 12.0,
    //                           //                 color: Colors.white),
    //                           //           ),
    //                           //         ),
    //                           //       ),
    //                           //     )
    //                           //   ],
    //                           // ),
    //                         ),
    //                       ),
    //                       Container(
    //                         height:40.0,
    //                         width: 80.0,
    //
    //                         decoration: BoxDecoration(
    //                           color: Theme.of(context)
    //                               .primaryColor,
    //                           borderRadius:
    //                           BorderRadius.circular(30.0),
    //                           border: Border.all(
    //                               width: 3.0,
    //                               color: Theme.of(context)
    //                                   .primaryColor),
    //                         ),
    //                         child: Center(
    //                           child: Text(
    //                             'Basic',
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 12.0,
    //                                 color: Colors.white),
    //                           ),
    //                         ),
    //                       ),
    //                     ]
    //
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // });

    /*  showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white10,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white70,
              ),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Center(
                          child: Text("Subscription",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ))),
                      SizedBox(height: 10.0),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.7 / 3,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.7 / 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '8,49\$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                  '3 months Subscription',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                                // Text(
                                //   '\$2.99',
                                //   style: TextStyle(
                                //     fontSize: 12.0,
                                //   ),
                                // ),
                                // InkWell(
                                //   onTap:(){
                                //     Navigator.pop(context);
                                //
                                //     showBottomSheet('basic','299',context);
                                //   },
                                //   child: Container(
                                //     height:40.0,
                                //     width: 80.0,
                                //
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context)
                                //           .primaryColor,
                                //       borderRadius:
                                //       BorderRadius.circular(30.0),
                                //       border: Border.all(
                                //           width: 3.0,
                                //           color: Theme.of(context)
                                //               .primaryColor),
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         'Basic',
                                //         style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 12.0,
                                //             color: Colors.white),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          Container(
                            height: 40.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Bronze',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 0.7 / 3 - 10,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.7 / 3 -
                                    10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '12,49\$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                  '6 months Subscription',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                                // Text(
                                //   '\$2.99',
                                //   style: TextStyle(
                                //     fontSize: 12.0,
                                //   ),
                                // ),
                                // InkWell(
                                //   onTap:(){
                                //     Navigator.pop(context);
                                //
                                //     showBottomSheet('basic','299',context);
                                //   },
                                //   child: Container(
                                //     height:40.0,
                                //     width: 80.0,
                                //
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context)
                                //           .primaryColor,
                                //       borderRadius:
                                //       BorderRadius.circular(30.0),
                                //       border: Border.all(
                                //           width: 3.0,
                                //           color: Theme.of(context)
                                //               .primaryColor),
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         'Basic',
                                //         style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 12.0,
                                //             color: Colors.white),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          Container(
                            height: 40.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Gold',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 0.7 / 3 - 10,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(alignment: Alignment.topRight, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.height * 0.7 / 3 -
                                    10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '15,99\$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                  '12 months Subscription',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                                // Text(
                                //   '\$2.99',
                                //   style: TextStyle(
                                //     fontSize: 12.0,
                                //   ),
                                // ),
                                // InkWell(
                                //   onTap:(){
                                //     Navigator.pop(context);
                                //
                                //     showBottomSheet('basic','299',context);
                                //   },
                                //   child: Container(
                                //     height:40.0,
                                //     width: 80.0,
                                //
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context)
                                //           .primaryColor,
                                //       borderRadius:
                                //       BorderRadius.circular(30.0),
                                //       border: Border.all(
                                //           width: 3.0,
                                //           color: Theme.of(context)
                                //               .primaryColor),
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         'Basic',
                                //         style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 12.0,
                                //             color: Colors.white),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          Container(
                            height: 40.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Center(
                              child: Text(
                                'Platinum',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () {
                          print("Next Pressed");
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (_) => SubscriptionOptions(
                                      subscriptionExpired: subscriptionExpired,
                                      userId: userId)));
                          // Navigator.pop(context);
                        },
                        child: Container(
                          height: 40.0,
                          width: 120.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                                width: 3.0,
                                color: Theme.of(context).primaryColor),
                          ),
                          child: Center(
                            child: Text(
                              'Next',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });*/
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      DocumentReference reference =
          Firestore.instance.collection('Users').document(userId);
      Firestore.instance.runTransaction((transaction) {
        return transaction.update(reference, {'status': 'Online'});
      });
    } else {
      DocumentReference reference =
          Firestore.instance.collection('Users').document(userId);
      Firestore.instance.runTransaction((transaction) {
        return transaction.update(reference, {'status': 'Offline'});
      });
    }
  }

  getServiceProviderProfile() async {
    QuerySnapshot allSuperUsers = await Firestore.instance
        .collection('SuperUser')
        .where("expired", isEqualTo: false)
        .getDocuments();
    setState(() {
      loadingUsers = true;
    });

    if (!check) {
      await getLocation();
    }

    setState(() {
      loadingUsers = false;
      usersList = allSuperUsers.documents;
      usersList.shuffle();
    });
  }

  getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final coordinates =
          new Coordinates(position.latitude, position.longitude);

      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      setState(() {
        country = addresses.first.countryName;
        check = true;
      });
    } catch (e) {
      if (e is PermissionDeniedException) {
        print(e);
      }
      return null;
    }
  }

  void navigateToSearchPage(String currentUserID) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BusinessUserSearchScreen(currentUserID);
    }));
  }

  Widget _bottomBar() {
    return BottomNavyBar(
      containerHeight: 65,
      selectedIndex: _currentIndex,
      onItemSelected: (index) {
        setState(() => _currentIndex = index);
        print(index);
        _pageController.jumpToPage(index);
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          title: Text('Home'),
          icon: Icon(Icons.home),
        ),
        BottomNavyBarItem(
            title: Text('Saved'),
            icon: Icon(
              Icons.favorite_border,
            ),
            activeColor: Colors.red),
        BottomNavyBarItem(
            title: Text('Search'),
            icon: Icon(Icons.share_outlined),
            activeColor: Colors.purple),
        BottomNavyBarItem(
            title: Text('Messages'),
            icon: Icon(Icons.send),
            activeColor: Colors.orange),
      ],
    );
  }

  void navigateToUserProfilePage(DocumentSnapshot snapshot,
      BuildContext context, String userId, DocumentSnapshot snapshot2) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (_) => StoryProfiles(
                UserProfiles(
                    snapshot.documentID,
                    snapshot.data['name'],
                    snapshot.data['avatarUrl'],
                    snapshot.data['address'],
                    snapshot2.data['category']),
                userId)));
  }
}

// class HelloText extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       margin: subscriptionExpired == false ? EdgeInsets.only(top: 70.0,left: 20.0):EdgeInsets.only(top: 150.0,left: 20.0),
//       child: Text(
//         "Explore Popular Categories",
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Helvetica',
//             fontSize: 14),
//       ),
//     );
//   }
// }

class TopText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Hey there,",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica',
                      fontSize: 24),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "See Tariffo's suggestions...",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Helvetica',
                      fontSize: 15),
                ),
              ],
            )
          ],
        ));
  }
}

class Appbar extends StatelessWidget {
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0.0, -10),
        child: Container(
            height: 50,
            margin: EdgeInsets.only(left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(80),
              ),
              child: BottomAppBar(
                color: Colors.white24,
                elevation: 200,
                shape: CircularNotchedRectangle(),
                notchMargin: 20.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FavoriteProviders()));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CustomerPosts()));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (_) => MessageList()));
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) => StoryScreen(stories: stories)),
//                );
                      },
                    ),
                  ],
                ),
              ),
            )));
  }
}
