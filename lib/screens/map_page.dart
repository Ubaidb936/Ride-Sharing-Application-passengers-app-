import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:brand_colors/brand_colors.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/datamodels/address.dart';
import 'dart:io';
import 'package:sumostand/divider.dart';
import 'package:sumostand/constanst.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sumostand/geocoding/helpermethods.dart';
import 'package:sumostand/screens/loginpage.dart';
import 'package:sumostand/screens/searchpage.dart';
import 'package:sumostand/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MapPage extends StatefulWidget {
  static String id = 'mappage';
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String pickUp;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapPadding = 0;
  double height = Platform.isIOS ? 300 : 275;

  var geoLocator = Geolocator();
  Position currentPosition;
  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    var pickUp = await HelperMethod.findCoordinateAddress(position, context);




  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 160,
                child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/user_icon.png"),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubaid ul Majied',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'View profile',
                              style: TextStyle(
                                  color: BrandColors.appleLightGray),
                            )
                          ],
                        )
                      ],
                    )),
              ),
              DividerWidget(),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides', style: KDrawerItemStyle),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(OMIcons.payment),
                title: Text('Payments', style: KDrawerItemStyle),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides', style: KDrawerItemStyle),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Ride History', style: KDrawerItemStyle),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support', style: KDrawerItemStyle),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),

        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapPadding = Platform.isIOS ? 270 : 280;
                });
                setupPositionLocator();
              },
            ),
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: (){
                  _drawerKey.currentState.openDrawer();
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
                      Icons.menu,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: height,
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
                        Text('kut chu gasun',
                            style: kMessageTextStyle),
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
                        onTap: (){
                          Navigator.pushNamed(context, SearchPage.id, arguments: Address(placeName: pickUp));
                        },
                        child: CustomButtons()
                    ),
                    SizedBox(height: 10),
                    // Container(
                    //     child: Row(
                    //   children: [
                    //     Icon(
                    //       OMIcons.home,
                    //       size: 40,
                    //       color: Colors.grey,
                    //     ),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text('Home'),
                    //         Text(
                    //           'NewColney, Agrikalan',
                    //           style: TextStyle(
                    //               color: BrandColors.appleLightGray),
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    // )),
                    // DividerWidget(),
                    // SizedBox(height: 10),
                    // Container(
                    //     child: Row(
                    //   children: [
                    //     Icon(
                    //       OMIcons.workOutline,
                    //       size: 40,
                    //       color: Colors.grey,
                    //     ),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text('Home'),
                    //         Text(
                    //           'NewColney, Agrikalan',
                    //           style: TextStyle(
                    //               color: BrandColors.appleLightGray),
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    // ))
                  ],
                ),
              ),
            ),
          ],
        ),

    );
  }
}