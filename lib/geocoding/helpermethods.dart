import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/datamodels/directionDetails.dart';
import 'package:sumostand/datamodels/user.dart';
import 'package:sumostand/global_variables.dart';
import 'requesthelper.dart';
import 'package:sumostand/datamodels/user.dart';


class HelperMethod{

    static Future<dynamic> findCoordinateAddress(Position position, context) async{

      String placeAddress = 'failed';
      String url = "https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude}, ${position.latitude}.json?access_token=${mapBoxKey}";
      var data = await RequestHelper.getRequest(url);
       print("Data Below____________________________________________________________________________");

      if(data != 'failed'){

         placeAddress = data['features'][0]['place_name'];
         //print(placeAddress);
         Address pickUpAddress = new Address(placeName: placeAddress, latitude: position.latitude, longitude: position.longitude);
         Provider.of<AppData>(context, listen: false).updateAddress(pickUpAddress);
         //print(Provider.of<AppData>(context, listen: false).pickUpAddress.placeName);
      }

       return placeAddress;

    }

    static double generateRandomNumber(max){

      var randomGenerator = Random();

      int radInt = randomGenerator.nextInt(max);

      return radInt.toDouble();



    }

     static Future<DirectionDetails> getDirectionsDetails(LatLng startingPosition, LatLng endPosition) async{

      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${startingPosition.latitude},${startingPosition.longitude}&destination=${endPosition.latitude}, ${endPosition.longitude} & mode=driving&key=${mapKey}";
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return null;
      }

      if (response['status'] == 'OK') {
        DirectionDetails directionDetails = DirectionDetails();
        directionDetails.durationText = response['routes'][0]["legs"][0]["duration"]["text"];
        directionDetails.distanceText = response['routes'][0]["legs"][0]["distance"]["text"];
        directionDetails.durationValue = response['routes'][0]["legs"][0]["duration"]["value"];
        directionDetails.distanceValue = response['routes'][0]["legs"][0]["distance"]["value"];
        directionDetails.encodedPoints = response['routes'][0]["overview_polyline"]["points"];
        return directionDetails;
      }

    }

    static int calculateFare(DirectionDetails directionDetails){

       int baseFare = 10;
       int distanceFare = ((directionDetails.distanceValue/1000)*2).truncate();
       int durationFare = ((directionDetails.durationValue/60)*1).truncate();

       return baseFare + distanceFare + durationFare;

    }
    static void getUserDetails() async{

       currentFirebaseUser =   FirebaseAuth.instance.currentUser;
       String userId = currentFirebaseUser.uid;

       DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/$userId');

       userRef.once().then(( DataSnapshot snapshot){


         if(snapshot.value != null){


           userDetails = UserDetails.fromSnapshot(snapshot);
           print(userDetails.fullName);

         }


       });





    }

}