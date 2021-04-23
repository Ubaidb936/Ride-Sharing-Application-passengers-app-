
import 'package:firebase_database/firebase_database.dart';

class UserDetails{

  String email;
  String fullName;
  String  phone;
  String id;

  UserDetails({this.email, this.fullName, this.phone});


  UserDetails.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    email = snapshot.value['email'];
    phone = snapshot.value['phoneNumber'];
    fullName = snapshot.value['fullName'];
  }



}