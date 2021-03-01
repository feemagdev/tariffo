import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tariffo/choosedBusinessUser.dart';
import 'SignUp.dart';
import 'brazierContainer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginScreen.dart';
import 'HomePage.dart';
import 'auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  print(email);
  runApp(MaterialApp(home: email == null ? LoginPage() : Homepage()));
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;
  final Authentication authentication = Authentication();
  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            body: Container(
              height: 900.0,
              width: 500.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Tariffo',
                        style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'SignPainter',
                            fontSize: 60),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 400.0,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0, top: 40.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val.isEmpty ? 'enter email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: 'enter email',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Antra',
                                        fontSize: 12.0,
                                        color: Colors.black)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0, top: 40.0),
                              child: TextFormField(
                                validator: (val) => val.length < 8
                                    ? 'enter password > 8 digits'
                                    : null,
                                onChanged: (val) {
                                  setState(() => password = val);
                                },
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: 'enter password',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Antra',
                                        fontSize: 12.0,
                                        color: Colors.black)),
                                obscureText: true,
                              ),
                            ),
                            SizedBox(height: 50),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: MaterialButton(
                                height: 50,
                                minWidth: 300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Colors.blue,
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString(
                                      'email', 'useremail@gmail.com');
                                  if (_formKey.currentState.validate()) {
                                    setState(() => loading = true);
                                    String result = await authentication
                                        .signInWithEmailAndPassword(
                                            email, password);

                                    print('result at login page $result');
                                    if (result == null) {
                                      setState(() => error =
                                          'Sorry,These credentials will not work out');
                                      loading = false;
                                      errorAlert();
                                    } else {
                                      DocumentSnapshot userData =
                                          await Firestore.instance
                                              .collection('Users')
                                              .document(result)
                                              .get();

                                      if ((userData.data['country'] == null ||
                                              userData.data['country'] == '') &&
                                          userData.data['userRole'] ==
                                              'Business') {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return BusinessPage();
                                        }));
                                      } else {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return Homepage();
                                        }));
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontFamily: 'Antra', color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              alignment: Alignment.centerRight,
                              child: Text('Forgot Password ?',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      )),
                  _createAccountLabel(),
                ],
              ),
            ),
          );
  }

  errorAlert() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Login Error",
      desc: error,
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignupPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Don't you have an account ?",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
