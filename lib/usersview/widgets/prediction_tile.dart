import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sumostand/dataProvider/appdata.dart';
import 'package:sumostand/datamodels/address.dart';
import 'package:sumostand/datamodels/prediction.dart';
import 'package:sumostand/geocoding/requesthelper.dart';
import 'package:sumostand/global_variables.dart';
import 'package:provider/provider.dart';
class PredictionTile extends StatelessWidget {

  final Prediction prediction;

  PredictionTile({this.prediction});

  //PLACE DETAIL API
  void getPlaceDetails(context) async{


    final ProgressDialog pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    pr.style(
        message: 'please wait',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    await pr.show();


    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&key=$mapKey";

    var response = await RequestHelper.getRequest(url);
    await pr.hide();

    if(response == "failed"){
      return;
    }

    if(response["status"] == 'OK'){
      Address destination = Address();
      destination.placeId = prediction.placeId;
      destination.placeName = response["result"]["address_components"][1]["long_name"];
      destination.latitude =  response["result"]["geometry"]["location"]["lat"];
      destination.longitude =  response["result"]["geometry"]["location"]["lng"];
      destination.placeFormattedAddress = response["result"]["formatted_address"];

      Provider.of<AppData>(context, listen: false).updateDestinationAddress(destination);
      print(Provider.of<AppData>(context, listen: false).destinationAddress.placeName);


    }

    Navigator.pop(context, 'getDirections');

  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){

       getPlaceDetails(context);
       print(prediction.placeId);


      },
      child: Container(
        child: Column(

          children: [
            Row(
              children: [
                Icon(OMIcons.locationOn),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text('${prediction.mainText}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15),),
                      SizedBox(height: 2,),
                      Text('${prediction.secondaryText}, ', overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 10,color:Colors.grey )),

                    ],

                  ),
                )
              ],
            ),



          ],


        ),
      ),
    );
  }
}