import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sumostand/screens/map_page.dart';
import 'package:sumostand/screens/registrationPage.dart';
class LoginPage extends StatefulWidget {
  static String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  var emailController = TextEditingController();

  var passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState>scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title){

    final snackBar = SnackBar(content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20),));
    scaffoldKey.currentState.showSnackBar(snackBar);

  }

  void loginUser() async{



      User user = (await _auth.signInWithEmailAndPassword(

          email: emailController.text,
          password: passwordController.text

      ).catchError((ex){

        FirebaseException thisEx = ex;
        showSnackBar(thisEx.message);

      })).user;

      if(user != null ){
        Navigator.pushNamed(context, MapPage.id);
      }
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


          TextField(
            controller: emailController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Email Address',
                fillColor: Colors.grey[200],
                filled: true
            ),
          ),
          SizedBox(height: 20),

          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
                fillColor: Colors.grey[200],
                filled: true
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () async{



              var connectivityResult = await (Connectivity().checkConnectivity());

              if(connectivityResult != ConnectivityResult.wifi && connectivityResult != ConnectivityResult.mobile){
                showSnackBar('check internet connection');
              }

              if(!emailController.text.contains('@')){

                showSnackBar('please enter valid email address');

              }
              if(passwordController.text.length < 8){

                showSnackBar('Password must be 8 characters');

              }
              loginUser();

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
                child: Center(child: Text('Login'))


            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, Registration.id);
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )

        ],

      ),

    );
  }
}