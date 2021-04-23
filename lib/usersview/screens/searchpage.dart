import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:brand_colors/brand_colors.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/datamodels/prediction.dart';
import 'package:sumostand/geocoding/requesthelper.dart';
import 'package:sumostand/global_variables.dart';
import 'package:sumostand/usersview/widgets/prediction_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity/connectivity.dart';

class SearchPage extends StatefulWidget {
  static String id = 'searchPage';
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController pickUpController = new TextEditingController();
  TextEditingController destinationController = new TextEditingController();
  var uuid = Uuid();
  var connectivityResult;

  var focusDestination = FocusNode();

  List<Prediction> destinationPredictionList = [];

  bool isFocused = false;
  void setFocus() {
    if (!isFocused) {
      isFocused = true;
      FocusScope.of(context).requestFocus(focusDestination);
    }
  }


  void checkInternet() async{
    connectivityResult = await (Connectivity().checkConnectivity());
  }



  //Search API
  void searchPlace(String placeName) async {
    if (placeName != null && placeName.length > 0) {
      String id = uuid.v4();
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&radius=500&key=$mapKey&sessiontoken=$id&components=country:in';

      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];


        List<Prediction> thisList = [];
        (predictionJson as List).forEach((element) {


              Prediction pre = Prediction.fromJson(element);
              // print(pre.secondaryText);
              // print(pre.secondaryText.length);
              if(pre.secondaryText != null){
                thisList.add(pre);
              }

        });

        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    setFocus();

    // if(connectivityResult != ConnectivityResult.wifi && connectivityResult != ConnectivityResult.mobile){
    //
    //   showSnackBar('check internet connection');
    //
    // }
    String pickUpAddress =
        Provider.of<AppData>(context).pickUpAddress.placeName ?? 'magam';
    pickUpController.text = pickUpAddress;

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Center(
                            child: Text('Search Destination',
                                style: TextStyle(
                                    fontFamily: 'Brand-bold', fontSize: 20))),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/pickicon.png"),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: Container(
                          height: 40,
                          child: TextField(
                            controller: pickUpController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Pickup Location',
                                fillColor: Colors.grey[200],
                                filled: true),
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/desticon.png"),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: Container(
                          height: 40,
                          child: TextField(
                            onChanged: (value) {
                              searchPlace(value);
                            },
                            focusNode: focusDestination,
                            controller: destinationController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Destination',
                                fillColor: Colors.grey[200],
                                filled: true),
                          ),
                        ))
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Divider(
              thickness: 1,
            ),

            (destinationPredictionList.length > 0 && destinationController.text.length > 0) ?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return PredictionTile(
                      prediction: destinationPredictionList[index]);
                },
                separatorBuilder: (BuildContext context, index) => Divider(),
                itemCount: destinationPredictionList.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,

              ),
            ): Container(child: Text(""),),

          ],
        ),
      ),
    );
  }
}
