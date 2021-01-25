import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 350,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.lightBlue,
            ),
            SizedBox(width: 5,),
            Text('Search Destination'),
          ],
        ));
  }
}