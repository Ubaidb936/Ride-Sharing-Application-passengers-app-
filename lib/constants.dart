import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


const KDrawerItemStyle = TextStyle(fontSize: 16);

const kMessageTextStyle = TextStyle(
                           color: Colors.black,
                           fontWeight: FontWeight.bold,
                           fontSize: 20);
final CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);