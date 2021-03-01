import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tariffo/HomePage.dart';
import 'package:tariffo/SignUp.dart';
import 'auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'LoginPage.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  print(email);
  runApp(MaterialApp(home: LoginPage()));
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final Authentication authentication = Authentication();

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Logo(),
              SizedBox(height: 60),
              CarouselDemoState(),
              SizedBox(height: 40),
              SignUpButton(),
              SizedBox(height: 40),
              LoginButton(),
              SizedBox(height: 40),
             

              // <-- Built with StreamBuilder
            ],
          )),
    );
  }
}

class UserProfile extends StatefulWidget {
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  initState() {
    super.initState();

    // Subscriptions are created here
    //  authService.profile.listen((state) => setState(() => _profile = state));

    //authService.loading.listen((state) => setState(() => _loading = state));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(padding: EdgeInsets.all(20), child: Text(_profile.toString())),
      Text(_loading.toString())
    ]);
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 300,
        child: RaisedButton(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
                Text('        I already have an account')
              ]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            // Navigate to second route when tapped.
          },
        ));
  }
}

class SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 300,
        child: RaisedButton(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
                Text('                Create Account')
              ]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
            // Navigate to second route when tapped.
          },
        ));
  }
}



class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'Tariffo',
            style: TextStyle(
                color: Colors.blue, fontFamily: 'SignPainter', fontSize: 60),
          ),
        ]);
  }
}

class CarouselDemoState extends StatelessWidget {
  int _current = 0;
  List imgList = [
    'https://www.freepnglogos.com/uploads/box-png/box-new-used-gaylord-boxes-for-sale-reliable-industries-llc-22.png',
    'https://www.chefmarcsmealprep.com/wp-content/uploads/2018/03/kisspng-health-food-healthy-diet-meal-delivery-service-weight-loss-5b649d89de2764.36415564153332058591.png',
    'https://freepngimg.com/thumb/air_pump/49352-8-garden-tools-free-download-png-hq.png',
    'https://www.jwcommercialcleaning.com/wp-content/uploads/Janitorial-Services-Gainesville-FL.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CarouselSlider(
          options: CarouselOptions(
              height: 200.0, enableInfiniteScroll: true, autoPlay: true),
          items: imgList.map((imgUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(color: Colors.white10),
                  child: Image.network(imgUrl, fit: BoxFit.fill),
                );
              },
            );
          }).toList(),
        )
      ],
    );
  }
}
