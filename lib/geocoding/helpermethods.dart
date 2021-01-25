import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/global_variables.dart';
import 'requesthelper.dart';


class HelperMethod{

    static Future<dynamic> findCoordinateAddress(Position position, context) async{

      String placeAddress = 'failed';
      String url = "https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude}, ${position.latitude}.json?access_token=${mapBoxKey}";
      var data = await RequestHelper.getRequest(url);
      // print("Data Below____________________");

      if(data != 'failed'){
         placeAddress = data['features'][0]['place_name'];
         print(placeAddress);
         Address pickUpAddress = new Address(placeName: placeAddress, latitude: position.latitude, longitude: position.longitude);
         Provider.of<AppData>(context, listen: false).updateAddress(pickUpAddress);
         //print(Provider.of<AppData>(context).pickUpAddress.placeName);

      }

       return placeAddress;

    }

}