import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:tariffo/transport_category.dart';

class CategoriesScroller extends StatelessWidget {
  const CategoriesScroller();

  @override
  Widget build(BuildContext context) {
    final double categoryHeight =
        MediaQuery.of(context).size.height * 0.30 - 50;
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: FittedBox(
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Transport Services", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://www.midwestmoving.com/wp-content/uploads/2019/02/Man-Carrying-Sofa-When-Moving-into-New-House-1080x675.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Transport\nservices",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Electric Services", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://teamelectricinc.com/wp-content/uploads/2019/04/shutterstock_1009276942.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Electric\nservices",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Construction Services", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://bondoc-asociatii.ro/wp-content/uploads/2018/05/Competition11.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Construction\nservices",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Veterinary clinics", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://images.adsttc.com/media/images/5500/f053/e58e/ce81/2900/0132/large_jpg/Vet-Clinic-3small.jpg?1426124860"),
                            fit: BoxFit.cover),
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Veterinary\nclinics",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Clinics", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://www.aria.com.ro/static/divizii/955x570px-clinic1-816e6609ec221991ea9c53736eaf2910.png"),
                            fit: BoxFit.cover),
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Clinics",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Restaurants", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://hoteldelcorso.ro/img/94930_D8A3444-FB.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Restaurants",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Cleaning Companies", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://www.eazybee.fi/wp-content/uploads/2020/05/Easybee-cleaning-service.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.blue.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Cleaning\nCompanies",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    List<String> location = await getLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TransportScreen("Salons", location)),
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.only(right: 20),
                    height: categoryHeight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://www.beautycosmetic.ro/blog/wp-content/uploads/2018/04/beuhair-interior-3-min-cropped.jpg"),
                            fit: BoxFit.cover),
                        color: Colors.lightBlueAccent.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Salons",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
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
  }

  Future<List<String>> getLocation() async {
    List<String> locationList = List();
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final coordinates =
          new Coordinates(position.latitude, position.longitude);

      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      locationList.add(addresses.first.countryName);
      locationList.add(addresses.first.countryCode);
      print('in get location ');
      print(locationList[0] + "   " + locationList[1]);
      return locationList;
    } catch (e) {
      if (e is PermissionDeniedException) {
        print(e);
      }
      return locationList;
    }
  }
}
