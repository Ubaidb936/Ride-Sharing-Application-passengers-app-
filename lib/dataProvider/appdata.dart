import 'package:flutter/material.dart';
import 'package:sumostand/datamodels/address.dart';


class AppData extends ChangeNotifier{

  Address pickUpAddress;
  void updateAddress(Address pickUp){

    pickUpAddress = pickUp;
    notifyListeners();

  }
}