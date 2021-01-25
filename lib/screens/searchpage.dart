import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:brand_colors/brand_colors.dart';
import 'package:sumostand/datamodels/address.dart';

class SearchPage extends StatefulWidget {

  static String id = 'searchPage';
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController pickUpController;
  @override
  Widget build(BuildContext context) {

    //pickUpController.text = Provider.of<AppData>(context).pickUpAddress.placeName ?? '';
    //final Address args = ModalRoute.of(context).settings.arguments;
    //pickUpController.text = args.placeName;
    //TextEditingController _controller = new TextEditingController();


    //_controller.text = args.placeName;
    return Scaffold(

      body: SafeArea(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [


            SizedBox(
              height: 10,
            ),
            Container(

              height: 210,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(

                      children: [



                        Icon(
                          Icons.arrow_back,
                          color: Colors.black,

                        ),

                        Center(
                            child: Text('Search Destination',
                                style: TextStyle(

                                  fontFamily: 'Brand-bold',
                                  fontSize: 20

                                )
                            )
                        ),





                      ],


                    ),

                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Image.asset("assets/images/pickicon.png"),
                        SizedBox(width: 50,),

                        Expanded(
                            child: Container(
                              height: 40,
                              child: TextField(
                                //controller: _controller,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Pickup Location',
                                  fillColor: Colors.grey[200],
                                  filled: true
                                ),
                              ),

                            )

                        )

                      ],


                    ),
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Image.asset("assets/images/desticon.png"),
                        SizedBox(width: 50,),

                        Expanded(
                            child: Container(
                              height: 40,
                              child: TextField(

                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Destination',
                                    fillColor: Colors.grey[200],
                                    filled: true
                                ),
                              ),

                            )

                        )

                      ],


                    ),





                  ],


                ),
              ),

            ),

            //
            // SizedBox(
            //   height: 30
            // ),
            //





          ],
        ),
      ),

    );
  }
}
