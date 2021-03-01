import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tariffo/UserProfiles.dart';
import 'package:tariffo/story_model.dart';

import 'StoryScreen.dart';
import 'UserProfiles.dart';

class StoryProfiles extends StatefulWidget {
  final UserProfiles profileWidget;
  final String currentUserId;
  StoryProfiles(this.profileWidget, this.currentUserId);
  @override
  _StoryProfileState createState() => _StoryProfileState();
}

class _StoryProfileState extends State<StoryProfiles> {
  Color bgColor = Colors.transparent;
  PanelState panelState = PanelState.CLOSED;

  PanelController panelController = PanelController();
  List<Story> _list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Firestore.instance
        .collection('Users/${widget.profileWidget.serviceProviderId}/Story')
        .getDocuments()
        .then((value) {
      if (value.documents.length == 0) {
        setState(() {
          panelState = PanelState.OPEN;
        });
      }
      value.documents.forEach((element) {
        setState(() {
          _list.add(Story(
              url: element.data['url'],
              media: element.data['media'],
              id: element.documentID));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // getBusinessProviderStoryData();

    return Scaffold(
      body: SlidingUpPanel(
          color: bgColor,
          defaultPanelState: panelState,
          onPanelOpened: () => setState(() => bgColor = Colors.white),
          onPanelClosed: () => setState(() => bgColor = Colors.transparent),
          panelBuilder: (ScrollController sc) {
            widget.profileWidget.scrollController = sc;
            return widget.profileWidget;
          },
          collapsed: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
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
          //body: Stack(children: <Widget>[StoryScreen(stories: stories)]),
          body: _list.length > 0
              ? StoryScreen(
                  stories: _list,
                  uid: widget.profileWidget.serviceProviderId,
                  currentUserID: widget.currentUserId,
                )
              : Container(
                  child: Center(
                    child: Text('User didn\'t share any story on profile'),
                  ),
                )),
    );
  }

  void getBusinessProviderStoryData() async {
    print(
        'serviceProviderId at view profiles   ${widget.profileWidget.serviceProviderId}');
    QuerySnapshot query = await Firestore.instance
        .collection('Users/${widget.profileWidget.serviceProviderId}}/Story')
        .getDocuments();

    for (DocumentSnapshot doc in query.documents) {
      print('hereeeeeee ${doc.data['media']}');

      print('hhhhhelo ${_list.length}');
    }
  }
}
