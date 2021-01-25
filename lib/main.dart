import 'dart:async';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/screens/loginpage.dart';
import 'package:sumostand/screens/map_page.dart';
import 'package:sumostand/screens/searchpage.dart';
import 'package:sumostand/screens/registrationPage.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app;
  try {
     app = await Firebase.initializeApp(
      name: 'db2',
      options: Platform.isIOS || Platform.isMacOS
          ? FirebaseOptions(
        appId: '1:5087372234:ios:d14a9ab3d025fae2d0e533',
        apiKey: 'AIzaSyDODpnkFmUXZJx7tuhV0MC1pVIAxJKFpHY',
        projectId: 'sumostand-3e4ed',
        messagingSenderId: '5087372234',
        databaseURL: 'https://sumostand-3e4ed.firebaseio.com',
      )
          : FirebaseOptions(
        appId: '1:5087372234:android:c3a7aa9acd32d433d0e533',
        apiKey: 'AIzaSyDbmMbj3Omv_K_HtaeubR3Q_c2sdxLWRHU',
        messagingSenderId: '5087372234',
        projectId: 'sumostand-3e4ed',
        databaseURL: 'https://sumostand-3e4ed.firebaseio.com',
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      app = Firebase.app('db2');
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }




  User currentFirebaseUser = FirebaseAuth.instance.currentUser;
  runApp( MyApp());
}




class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return ChangeNotifierProvider <AppData> (
      create: (context) => AppData() ,
      child: MaterialApp(

        debugShowCheckedModeBanner: false,
        initialRoute: (User == null)? LoginPage.id : MapPage.id,
        routes: {
          MapPage.id:  (context) => MapPage(),
          SearchPage.id:  (context) => SearchPage(),
          Registration.id: (context) => Registration(),
          LoginPage.id: (context) => LoginPage(),
        },

      ),
    );
  }
}




