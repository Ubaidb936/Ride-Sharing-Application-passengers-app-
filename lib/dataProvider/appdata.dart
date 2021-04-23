import 'package:flutter/material.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/datamodels/directionDetails.dart';

class AppData extends ChangeNotifier{

  Address pickUpAddress;
  Address destinationAddress;
  DirectionDetails directionDetails;
  void updateAddress(Address pickUp){

    if(pickUp != null){
      pickUpAddress = pickUp;
    }else{
      pickUpAddress = Address(placeName: "no internet");
    }

    notifyListeners();

  }

  void updateDestinationAddress(destination){

    destinationAddress = destination;
    notifyListeners();

  }
  void updateTripDetails(details){
    directionDetails = details;
    notifyListeners();
  }

}