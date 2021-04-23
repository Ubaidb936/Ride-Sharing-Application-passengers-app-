import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:brand_colors/brand_colors.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/datamodels/directionDetails.dart';
import 'dart:io';
import 'package:sumostand/divider.dart';
import 'package:sumostand/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sumostand/geocoding/helpermethods.dart';
import 'package:sumostand/geocoding/nearbyDriversList.dart';
import 'package:sumostand/login/screens/loginpage.dart';
import 'package:sumostand/usersview/screens/searchpage.dart';
import 'package:sumostand/usersview/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:sumostand/global_variables.dart';
import 'package:sumostand/datamodels/nearbydrivers.dart';
import 'package:sumostand/usersview/widgets/custom_drawer.dart';
import 'package:sumostand/project_colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapPage extends StatefulWidget {
  static String id = 'mappage';
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  double mapPadding = 0;
  double searchSheetHeight = Platform.isIOS ? 300 : 275;
  double confirmSheetHeight = 0;
  bool drawerCanOpen = true;
  double requestSheetHeight = 0;

  String pickUp;

  BitmapDescriptor nearbyIcon;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  var geoLocator = Geolocator();
  Position currentPosition;
  bool nearbyKeysLoaded = false;

  DatabaseReference rideRef;

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    var pickUp = await HelperMethod.findCoordinateAddress(position, context);
    startGeofireListner();
  }

  void startGeofireListner() {
    Geofire.initialize("driversAvailable");
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 100)
        .listen((map) {
      //print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver driver = NearbyDriver(
                key: map["key"],
                longitude: map["longitude"],
                latitude: map["latitude"]);
            NearbyDriversList.drivers.add(driver);
            if (nearbyKeysLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            NearbyDriversList.deleteDriver(map["key"]);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyDriver driver = NearbyDriver(
                key: map["key"].toString(),
                longitude: map["longitude"],
                latitude: map["latitude"]);
            NearbyDriversList.updateDriverLocation(driver);
            updateDriversOnMap();

            break;

          case Geofire.onGeoQueryReady:
            nearbyKeysLoaded = true;
            updateDriversOnMap();

            break;
        }
      }
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _Markers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyDriver driver in NearbyDriversList.drivers) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);

      Marker thisMarker = Marker(
          markerId: MarkerId('driver${driver.key}'),
          position: driverPosition,
          icon: nearbyIcon,
          rotation: HelperMethod.generateRandomNumber(360));

      tempMarkers.add(thisMarker);
    }

    setState(() {
      _Markers = tempMarkers;
    });
  }

  void createCustomIcon() {
    if (nearbyIcon == null) {
      //ImageConfiguration imageConfiguration = CreateLocalImageConfiguration(context, Size(2,2));
      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/images/car_android.png')
          .then((onValue) {
        nearbyIcon = onValue;
      });
    }
  }

  void updateSheetHeight() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      confirmSheetHeight = 250;
      mapPadding = Platform.isIOS ? 230 : 240;
      drawerCanOpen = false;
    });
  }

  void resetDetails() {
    setState(() {
      searchSheetHeight = Platform.isIOS ? 300 : 275;
      confirmSheetHeight = 0;
      requestSheetHeight = 0;
      mapPadding = Platform.isIOS ? 270 : 280;
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      drawerCanOpen = true;
      setupPositionLocator();
    });
  }

  void showRequestSheet() {
    setState(() {
      confirmSheetHeight = 0;
      requestSheetHeight = 195;
      drawerCanOpen = true;
    });

    makeRideRequest();
  }

  void makeRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    Address ridePickup =
        Provider.of<AppData>(context, listen: false).pickUpAddress ?? null;

    Address rideDestination =
        Provider.of<AppData>(context, listen: false).destinationAddress ?? null;

    Map pickUpLatLng = {
      'lat': ridePickup.latitude,
      'lng': ridePickup.longitude,
    };

    Map destinationLatLng = {
      'lat': rideDestination.latitude,
      'lng': rideDestination.longitude,
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': userDetails.fullName,
      'rider_phone': userDetails.phone,
      'rider_email': userDetails.email,
      'pick_up': ridePickup.placeName,
      'destination': rideDestination.placeName,
      'driver_id': 'waiting',
      'pickUpLatLng': pickUpLatLng,
      'destinationLatLng': destinationLatLng
    };
    rideRef.set(rideMap);
  }

  @override
  void initState() {
    // TODO: implement initState
    createCustomIcon();
    HelperMethod.getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DirectionDetails thisDetails =
        Provider.of<AppData>(context).directionDetails ?? null;

    return Scaffold(
      key: _drawerKey,
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          //GOOGLE MAP
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            polylines: _polylines,
            zoomControlsEnabled: true,
            markers: _Markers,
            circles: _Circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapPadding = Platform.isIOS ? 270 : 280;
              });
              setupPositionLocator();
            },
          ),

          //DRAWER
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                drawerCanOpen
                    ? _drawerKey.currentState.openDrawer()
                    : resetDetails();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          )),
                    ]),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          //SEARCH SHEET
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text('Aslamualaikum!', style: kMessageTextStyle),
                        Text('kut chu gasun', style: kMessageTextStyle),
                        Divider(
                          thickness: 2,
                          indent: 100,
                          endIndent: 100,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                        onTap: () async {
                          var response = await Navigator.pushNamed(
                              context, SearchPage.id,
                              arguments: Address(placeName: pickUp));

                          if (response == 'getDirections') {
                            updateSheetHeight();
                          }
                        },
                        child: CustomButtons()),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          //REQUEST RIDE SHEET
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              vsync: this,
              duration: new Duration(microseconds: 150),
              child: Container(
                height: confirmSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/carlogo.png",
                                height: 100,
                                width: 100,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(thisDetails != null
                                      ? thisDetails.distanceText
                                      : ' '),
                                ],
                              ),
                              Spacer(),
                              Text(
                                (thisDetails != null)
                                    ? "₹${HelperMethod.calculateFare(thisDetails)}"
                                    : " ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.moneyBillAlt),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Cash",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Spacer(),
                              Icon(
                                FontAwesomeIcons.greaterThan,
                                color: Colors.grey,
                                size: 15,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    //RIDE CONFIRM BUTTON
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.black,
                          child: FlatButton(
                            child: Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              showRequestSheet();
                              // showRequestSheet();
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //WAITING FOR RIDE SHEET
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                height: requestSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7)),
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: TextLiquidFill(
                      //     text: 'Requesting a ride...',
                      //     waveColor: ProjectColors.colorTextSemiLight,
                      //     boxBackgroundColor: Colors.white,
                      //     textStyle: TextStyle(
                      //       fontSize: 20.0,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //     boxHeight: 40.0,
                      //   ),
                      // ),

                      SpinKitWave(
                        color: Colors.grey,
                        size: 30.0,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Requesting a ride..."),

                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRide();
                          resetDetails();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  width: 1.0,
                                  color: ProjectColors.colorLightGrayFair)
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Cancel ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void cancelRide() {
    rideRef.remove();
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickUpAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var desLatLng = LatLng(destination.latitude, destination.longitude);

    DirectionDetails thisDetails =
        await HelperMethod.getDirectionsDetails(pickLatLng, desLatLng);

    Provider.of<AppData>(context, listen: false).updateTripDetails(thisDetails);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('polyid'),
          color: Color.fromARGB(255, 95, 109, 237),
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      _polylines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickLatLng.latitude > desLatLng.latitude &&
        pickLatLng.longitude > desLatLng.longitude) {
      bounds = LatLngBounds(southwest: desLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > desLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, desLatLng.longitude),
          northeast: LatLng(destination.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > desLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(desLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, desLatLng.longitude));
    } else {
      bounds = LatLngBounds(southwest: pickLatLng, northeast: desLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: desLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'My Location'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 20,
        center: pickLatLng,
        fillColor: Colors.green);

    Circle destinationCircle = Circle(
        circleId: CircleId('destination'),
        strokeColor: Colors.purple,
        strokeWidth: 3,
        radius: 20,
        center: desLatLng,
        fillColor: Colors.deepPurpleAccent);

    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }
}
