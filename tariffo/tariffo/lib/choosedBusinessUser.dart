import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_select/direct_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tariffo/HomePage.dart';
import 'auth.dart';
import 'LoginPage.dart';
import 'LoginScreen.dart';
import 'components.dart';

class BusinessPage extends StatefulWidget {
  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  String userId;
  var streat;
  var country;
  var locality;
  var postelCode;
  var category;

  String kGoogleApiKey = "AIzaSyAC_I8ue6so7SSBp3pZ6W44b9OT29sd2Z4";
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyAC_I8ue6so7SSBp3pZ6W44b9OT29sd2Z4");

  final _formKey = GlobalKey<FormState>();

  int selectedIndex1 = 0;
  int selectedIndex2 = 0;
  int selectedIndex3 = 0;

  TextEditingController controller = new TextEditingController();

  final elements1 = [
    "Electric Services",
    "Transport Services",
    "Pet Services",
    "Medical Services",
    "Clinics",
    "Construction Services",
    "Veterinary clinics",
    "Restaurants",
    "Cleaning Companies",
    "Salons"
  ];

  final elements2 = [
    "12 AM",
    "1 Am",
    "2 AM",
    "3 Am",
    "4 AM",
    "5 AM",
    "6 AM",
    "7 AM",
    "8 AM",
    "9 AM",
    "10 AM",
    "11 AM",
    "12 PM",
    "1 PM",
    "2 PM",
    "3 PM",
    "4 PM",
    "5 PM",
    "6 PM",
    "7 PM",
    "8 PM",
    "9 PM",
    "10 PM",
    "11 PM",
    "12 PM",
  ];

  final elements3 = [
    "12 AM",
    "1 Am",
    "2 AM",
    "3 Am",
    "4 AM",
    "5 AM",
    "6 AM",
    "7 AM",
    "8 AM",
    "9 AM",
    "10 AM",
    "11 AM",
    "12 PM",
    "1 PM",
    "2 PM",
    "3 PM",
    "4 PM",
    "5 PM",
    "6 PM",
    "7 PM",
    "8 PM",
    "9 PM",
    "10 PM",
    "11 PM",
    "12 PM",
  ];

  List<Widget> _buildItems1() {
    return elements1
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems2() {
    return elements2
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems3() {
    return elements3
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((value) => userId = value.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
//      resizeToAvoidBottomPadding: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
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
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(
//                        left: 40.0, right: 40.0, top: 40.0),
//                    child: TextFormField(
//                      validator: (val) =>
//                      val.isEmpty ? 'Enter street' : null,
//                      onChanged: (val) {
//                        setState(() => streat = val);
//                      },
//                      style: TextStyle(color: Colors.black),
//                      decoration: InputDecoration(
//                          hintText: 'Enter street',
//                          hintStyle: TextStyle(
//                              fontFamily: 'Antra',
//                              fontSize: 12.0,
//                              color: Colors.black)),
//                    ),
//                  ),
//                  SizedBox(height: 10),
//                  Padding(
//                    padding: const EdgeInsets.only(
//                        left: 40.0, right: 40.0, top: 40.0),
//                    child: TextFormField(
//                      validator: (val) =>
//                          val.isEmpty ? 'Postal Code' : null,
//                      onChanged: (val) {
//                        setState(() => postelCode = val);
//                      },
//                      style: TextStyle(color: Colors.black),
//                      decoration: InputDecoration(
//                          hintText: 'PostalCode',
//                          hintStyle: TextStyle(
//                              fontFamily: 'Antra',
//                              fontSize: 12.0,
//                              color: Colors.black)),
//                    ),
//                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(
//                        left: 40.0, right: 40.0, top: 40.0),
//                    child: TextFormField(
//                      validator: (val) => val.isEmpty ? 'Locality' : null,
//                      onChanged: (val) {
//                        setState(() => locality = val);
//                      },
//                      style: TextStyle(color: Colors.black),
//                      decoration: InputDecoration(
//                          hintText: 'Locality',
//                          hintStyle: TextStyle(
//                              fontFamily: 'Antra',
//                              fontSize: 12.0,
//                              color: Colors.black)),
//                    ),
//                  ),
//                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, top: 40.0),
                    child: TextFormField(
                      validator: (val) => val.isEmpty ? 'Location' : null,
                      controller: controller,
                      onTap: () async {
                        Prediction p = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: "AIzaSyAC_I8ue6so7SSBp3pZ6W44b9OT29sd2Z4",
                          mode: Mode.overlay, // Mode.fullscreen
                        );
                        displayPrediction(p, context);
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'Location',
                          hintStyle: TextStyle(
                              fontFamily: 'Antra',
                              fontSize: 12.0,
                              color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 10),

//                  Padding(
//                    padding: const EdgeInsets.only(
//                        left: 40.0, right: 40.0, top: 40.0),
//                    child: TextFormField(
//                      validator: (val) => val.isEmpty ? 'Category' : null,
//                      onChanged: (val) {
//                        setState(() => category = val);
//                      },
//                      style: TextStyle(color: Colors.black),
//                      decoration: InputDecoration(
//                          hintText: 'Category',
//                          hintStyle: TextStyle(
//                              fontFamily: 'Antra',
//                              fontSize: 12.0,
//                              color: Colors.black)),
//                    ),
//                  ),

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
                  SizedBox(height: 15.0),
                  Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    runSpacing: 10.0,
                    children: <Widget>[
                      Text(
                        'Start Time: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.0),
                      ),
                      DirectSelect(
                          itemExtent: 50.0,
                          selectedIndex: selectedIndex1,
                          backgroundColor: Colors.white30,
                          child: MySelectionItem(
                            isForList: false,
                            title: elements2[selectedIndex2],
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedIndex2 = index;
                            });
                          },
                          items: _buildItems2()),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'End Time: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.0),
                      ),
                      DirectSelect(
                          itemExtent: 50.0,
                          selectedIndex: selectedIndex1,
                          backgroundColor: Colors.white30,
                          child: MySelectionItem(
                            isForList: false,
                            title: elements3[selectedIndex3],
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedIndex3 = index;
                            });
                          },
                          items: _buildItems3()),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        Map<String, dynamic> data = {
                          'address': controller.text,
                          'country': country
                        };
                        DocumentReference reference = Firestore.instance
                            .collection('Users')
                            .document("$userId");

                        Firestore.instance.runTransaction((transaction) async {
                          transaction.update(reference, data);
                        });

                        Firestore.instance
                            .collection('Users/$userId/BusinessAccount')
                            .document('detail')
                            .setData({
                          'category': elements1[selectedIndex1],
                        }, merge: true).catchError((e) {
                          print(e);
                        });
                        Firestore.instance
                            .collection('${elements1[selectedIndex1]}')
                            .document('$userId')
                            .setData({
                          'id': '$userId',
                          'categoryName': elements1[selectedIndex1],
                          'openTime': elements2[selectedIndex2],
                          'closeTime': elements2[selectedIndex3],
                        }, merge: true).catchError((e) {
                          print(e);
                        });

                        Firestore.instance
                            .collection('SuperUser')
                            .document('$userId')
                            .setData({
                          'user': '$userId',
                          'expired_on': new DateTime.now()
                              .add(new Duration(days: 7))
                              .millisecondsSinceEpoch,
                          'plan': 'free',
                          'notified': false,
                          'expired': false,
                        });
                      }

                      print(new DateTime.now().add(new Duration(days: 7)));

                      Navigator.push(context,
                          new MaterialPageRoute(builder: (_) => Homepage()));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                          child: Text(
                        'Start your 7 days Trial',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p, BuildContext context) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);

      print('Place Id ${p.description}');
      print(address.first.countryName);

      controller.text = p.description;
      country = address.first.countryName;
    }
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
      height: 80.0,
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
