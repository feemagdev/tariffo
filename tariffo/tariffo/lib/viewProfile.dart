import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tariffo/story_model.dart';
import 'UserPage.dart';
import 'StoryScreen.dart';

class StoryProfile extends StatefulWidget {
  final String uid;
  final String currentUserID;

  StoryProfile({Key key, this.uid, this.currentUserID}) : super(key: key);
  @override
  _StoryProfileState createState() => _StoryProfileState();
}

class _StoryProfileState extends State<StoryProfile> {
  List<Story> storiesList = [];
  PanelController panelController = PanelController();
  Color bgColor = Colors.transparent;

  String currentUser;
  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection('Users/${widget.uid}/Story')
        .getDocuments()
        .then((value) {
      if (value.documents.length == 0) {
        print("No stories");
        panelController.open();
      }
      value.documents.forEach((element) {
        setState(() {
          storiesList.add(Story(
              url: element.data['url'],
              media: element.data['media'],
              id: element.documentID));
        });
      });

      getStoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        color: bgColor,
        controller: panelController,
        onPanelOpened: () => setState(() => bgColor = Colors.white),
        onPanelClosed: () => setState(() => bgColor = Colors.transparent),
        panelBuilder: (ScrollController sc) {
          UserPage pg = UserPage();
          pg.scrollController = sc;
          return pg;
        },
        collapsed: Container(
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                ),
                Text(
                  "SwipeUp to see more information",
                  style: TextStyle(color: Colors.white),
                ),
              
              ],
            ),
          ),
        ),
        body: storiesList.length > 0
            ? StoryScreen(
                stories: storiesList,
                uid: currentUser,
                currentUserID: currentUser,
              )
            : Container(
                child: Center(
                  child: Text('You didn\'t share any story on profile'),
                ),
              ),
      ),
    );
  }

  void getStoryData() async {
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        currentUser = value.uid;
      });
    }).whenComplete(() async {
      QuerySnapshot query = await Firestore.instance
          .collection('Users/$currentUser/Story')
          .getDocuments();
      storiesList.clear();
      if (query.documents.length != 0) {
        for (DocumentSnapshot doc in query.documents) {
          setState(() {
            storiesList.add(Story.fromDocument(doc));
          });
        }
      }
    });
  }
}
