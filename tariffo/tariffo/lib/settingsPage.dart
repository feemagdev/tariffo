import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tariffo/PrivacyAndSecurity.dart';
import 'package:tariffo/SubscriptionOptions.dart';
import 'package:tariffo/TermsAndConditions.dart';
import 'package:tariffo/existing_cards.dart';
import 'LoginScreen.dart';
import 'User.dart';
import 'auth.dart';
import 'new_payment_service.dart';

class SettingsPage extends StatefulWidget {
  final User user;

  const SettingsPage({Key key, @required this.user}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String curretnUserId;
  String userRole;
  bool values = false;

  var dateDifference;
  var dateDifferences;

  var date;
  var now;
  var diff;

  var noOfDays;
  var noOfHours;

  bool subscriptionExpired = false;

  @override
  void initState() {
    super.initState();

    StripeService.init();
    curretnUserId = widget.user.uid;
    userRole = widget.user.userRole;
  }

  @override
  Widget build(BuildContext context) {
    checkSubscription();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Text(
              "Settings",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            buttonResetPass(context, "Reset password"),
            widget.user.userRole == 'Customer'
                ? Container()
                : buildAccountOptionRow(context, "Promote your page"),
            termsAndConditions(context, "Terms and Conditions"),
            privacyAndSecurity(context, "Privacy and security"),
            generateQR(context, "Generate QR"),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            buildNotificationOptionRow("New for you", true),
            widget.user.userRole == 'Customer'
                ? Container()
                : buildNotificationOptionRow("Opportunity", true),
            SizedBox(
              height: 50,
            ),
            Center(
              child: OutlineButton(
                padding: EdgeInsets.symmetric(horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text("SIGN OUT",
                    style: TextStyle(
                        fontSize: 16, letterSpacing: 2.2, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row buildNotificationOptionRow(String title, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
        ),
        Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: isActive,
              onChanged: (bool val) {},
            ))
      ],
    );
  }

  GestureDetector buildAccountOptionRow(BuildContext contexts, String title) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: contexts,
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: 300.0,
                color: Colors.white12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)),
                  ),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Choose a plane for Profile Promotion',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                      width: 1.5,
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'BASIC',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '7 days',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '\$2.99',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);

                                          showBottomSheet(
                                              'basic', '299', context);
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: 80.0,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            border: Border.all(
                                                width: 3.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
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
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                      width: 1.5,
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'STANDARD',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '15 days',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '\$5.99',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);

                                          showBottomSheet(
                                              'Standard', '599', context);
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: 80.0,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            border: Border.all(
                                                width: 3.0,
                                                color: Colors.white),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Standard',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                      width: 1.5,
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '30 days',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        '\$9.99',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);

                                          showBottomSheet(
                                              'Premium', '999', context);
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                                width: 3.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Premium',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ));
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buttonResetPass(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Reset your password by email"),
                    TextFormField(
                      validator: (val) => val.isEmpty ? 'Enter Email' : null,
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
                    RaisedButton(
                      child: Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                      },
                    )
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close")),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector termsAndConditions(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Read the terms and conditions"),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Terms()),
                        );
                      },
                      child: Text(
                        "Read",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                    )
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close")),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector privacyAndSecurity(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Read Privacy and Security Doc"),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Privacy()),
                        );
                      },
                      child: Text(
                        "Read",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                    )
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close")),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector generateQR(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: QrImage(data: widget.user.uid),
                    ),
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close")),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  checkSubscription() async {
    await Firestore.instance
        .collection('SuperUser')
        .document(curretnUserId)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          now = DateTime.now();
          date = DateTime.fromMillisecondsSinceEpoch(value.data['expired_on']);
          diff = date.difference(now);
          subscriptionExpired = value.data['expired'];
        });
      }
    });
  }

  void showBottomSheet(
      String plan, String amountsTobeCharge, BuildContext contexts) {
    print("plan is " + plan);
    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  Icon icon;
                  Text text;

                  switch (index) {
                    case 0:
                      icon = Icon(Icons.add_circle,
                          color: Theme.of(context).primaryColor);
                      text = Text('Pay via new card');
                      break;
                    case 1:
                      icon = Icon(Icons.credit_card,
                          color: Theme.of(context).primaryColor);
                      text = Text('Pay via existing card');
                      break;
                  }

                  return InkWell(
                    onTap: () {
                      onItemPress(context, index, plan, amountsTobeCharge);
                    },
                    child: ListTile(
                      title: text,
                      leading: icon,
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).primaryColor,
                    ),
                itemCount: 2),
          );
        });
  }

  onItemPress(
      BuildContext context, int index, String plan, String amounts) async {
    print("plan is " + plan);
    print('amount at on Item Pressed ???  $amounts');

    switch (index) {
      case 0:
        if (subscriptionExpired == true) {
          payViaNewCard(context, plan, amounts);
        } else {
          print('already subscribed ');
        }

        break;
      case 1:
        if (subscriptionExpired == true) {
          print('going to existing screen');
          print("plan is " + plan);
          print("Current user" + curretnUserId);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (_) => ExistingCardsPage(
                      plan: plan,
                      amounts: amounts,
                      currentUserId: curretnUserId)));
        } else {
          print('already hjkkj subscribed ');
        }
        break;
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  payViaNewCard(BuildContext context, String plan, String amounts) async {
    Navigator.of(context).pop();
    print('amount at pay Via New Card???  $amounts');
    int planDays;
    DocumentReference reference =
        Firestore.instance.collection('SuperUser').document('$curretnUserId');

    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
        await StripeService.payWithNewCard(amount: amounts, currency: 'USD');
    await dialog.hide();
    var snackBar = SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    if (response.success == true) {
      switch (plan) {
        case "Basic":
          setState(() {
            planDays = 7;
          });

          break;
        case "Standard":
          setState(() {
            planDays = 15;
          });
          break;

        case "Premium":
          setState(() {
            planDays = 30;
          });
          break;
      }
      Firestore.instance.runTransaction((transaction) {
        return transaction.update(reference, {
          "expired": false,
          "expired_on": new DateTime.now()
              .add(new Duration(days: planDays))
              .millisecondsSinceEpoch,
          "notified": false,
          "plan": '$plan'
        });
      });
    }
  }
}
