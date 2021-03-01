import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:tariffo/HomePage.dart';
import 'auth.dart';
import 'LoginPage.dart';
import 'LoginScreen.dart';
import 'choosedBusinessUser.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  String _selectedRole = 'Select a User Role';
  String get selectedRole => _selectedRole;

  int selectedValue;
  String selectedString;

//  void setSelectedRole(String role) {
//    _selectedRole = role;
//  }

  bool loading = false;
  final Authentication authentication = Authentication();
  int selectedIndex1 = 0;

  final elements1 = [
    "Customer",
    "Business",
  ];

  List<Widget> _buildItems1() {
    return elements1
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            resizeToAvoidBottomInset: false,
//            resizeToAvoidBottomPadding: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30.0),
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
              padding: const EdgeInsets.only(top: 20.0),
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
            Expanded(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 30.0),
                        child: TextFormField(
                          validator: (val) => val.isEmpty ? 'enter name' : null,
                          onChanged: (val) {
                            setState(() => name = val);
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: 'Enter Name',
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
                          validator: (val) =>
                              val.isEmpty ? 'Enter Email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: 'Enter email',
                              hintStyle: TextStyle(
                                  fontFamily: 'Antra',
                                  fontSize: 12.0,
                                  color: Colors.black)),
                        ),
                      ),
                      SizedBox(height:10),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 20.0),
                        child: TextFormField(
                          validator: (val) => val.length < 8
                              ? 'enter password > 8 digits'
                              : null,
                          onChanged: (val) {
                            setState(() => password = val);
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: 'Enter Password',
                              hintStyle: TextStyle(
                                  fontFamily: 'Antra',
                                  fontSize: 12.0,
                                  color: Colors.black)),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      DirectSelect(
                          itemExtent: 50.0,
                          selectedIndex: selectedIndex1,
                          backgroundColor: Colors.white30,
                          child: MySelectionItem(
                            isForList: false,
                            title: elements1[selectedIndex1],
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedIndex1 = index;
                            });
                          },
                          items: _buildItems1()),
                          SizedBox(height: 30),
                      MaterialButton(
                        color: Colors.blue,
                        height: 50,
                        minWidth: 300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);

                            dynamic result = await authentication
                                .createUserWithEmailAndPassword(email, password,
                                    name, elements1[selectedIndex1]);
                            if (elements1[selectedIndex1] == 'Business') {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (_) => BusinessPage()));
                            } else {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (_) => Homepage()));
                            }
                            if (result == null) {
                              setState(() => error =
                                  'Sorry,These credentials will not work out');
                              loading = false;
                            }
                          }
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              fontFamily: 'Antra', color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _createAccountLabel(),
          ],
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Do you have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
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

class MySelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const MySelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(title),
    );
  }
}
