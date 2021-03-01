import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/google_nav_bar.dart';
import 'package:tariffo/post_model.dart';
import 'UserProfiles.dart';
import 'viewProfiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String userId;
String userName;
String userCity;
Post newPost;

class PostDetail extends StatefulWidget {

  String UserName;
  String Post;

  PostDetail(this.UserName, this.Post);

  @override
  PostDetailState createState() => PostDetailState();
}

class PostDetailState extends State<PostDetail> {
  TextEditingController textEditingController = TextEditingController();
  final database = Firestore.instance;
  String searchString;

  String post;
  final myController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
              child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 15),
                          Container(
                            //height: MediaQuery.of(context).size.height/2.2,
                            width: MediaQuery.of(context).size.width/1.1,
                            child:  Padding(
                              padding: EdgeInsets.all(30),
                              child:
                              Column(children: [

                                Text(widget.UserName,style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 15),
                                Text(
                                  widget.Post,

                                ),
                              ],)

                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(60),
                                  topRight: Radius.circular(60),
                                  bottomLeft: Radius.circular(60),
                                  bottomRight: Radius.circular(60)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),

                          ),
                          SizedBox(
                            height: 15,
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 50,),
                    Container(
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.5,
                        child: RaisedButton(
                            onPressed: () {

                            },
                            child: Text(
                              "Message",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            color: Colors.lightBlueAccent),
                      )
                    )

                  ])
          ),
        )
    );
  }
}


