import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:sumostand/screens/map_page.dart';
import 'package:sumostand/widgets/custom_input_field.dart';
class Registration extends StatefulWidget {
  static String id = 'registration';
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

   final FirebaseAuth _auth = FirebaseAuth.instance;



  final GlobalKey<ScaffoldState>scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title){

       final snackBar = SnackBar(content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20),));
       scaffoldKey.currentState.showSnackBar(snackBar);

  }


  void showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }


  void registerUser() async{

    //showLoaderDialog(context);
     final  User user = (await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      ).catchError((ex){

           FirebaseException thisEx = ex;
           showSnackBar(thisEx.message);

     })).user;

     if(user != null){
       ///problem here
       DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');



       Map userMap = {

         'fullName': fullNameController.text,
         'phoneNumber':phoneNumberController.text,
         'email': emailController.text


       };

       newUserRef.set(userMap);

       Navigator.pushNamed(context, MapPage.id);

     }

   // Navigator.pop(context);



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      // backgroundColor: Colors.green,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))

            ),
          ),
          SizedBox(height: 20),
          CustomInputField(textController: fullNameController, textInputType: TextInputType.name, hintText: 'FullName', obscureText: false,),

          SizedBox(height: 20),

          CustomInputField(textController: phoneNumberController, textInputType: TextInputType.phone, hintText: 'PhoneNumber', obscureText: false,),
          SizedBox(height: 20),

          CustomInputField(textController: emailController, textInputType: TextInputType.emailAddress, hintText: 'Email', obscureText: false,),
          SizedBox(height: 20),

          CustomInputField(textController: passwordController, textInputType: TextInputType.name, hintText: 'Password', obscureText: true,),

          SizedBox(height: 20),
          GestureDetector(
            onTap: () async{




               var connectivityResult = await (Connectivity().checkConnectivity());

               if(connectivityResult != ConnectivityResult.wifi && connectivityResult != ConnectivityResult.mobile){

                 showSnackBar('check internet connection');

               }

               if(fullNameController.text.length < 3){

                 showSnackBar('Please enter your full name');

               }


               if(phoneNumberController.text.length < 10){
                 showSnackBar('please enter 10 digit phoneNumber');
               }


               if(!emailController.text.contains('@')){

                 showSnackBar('please enter valid email addree');

               }
                      registerUser();

            },

            child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Center(child: Text('Register'))


            ),
          ),



        ],

      ),

    );
  }
}





