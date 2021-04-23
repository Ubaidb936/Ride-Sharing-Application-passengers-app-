import 'package:sumostand/datamodels/nearbydrivers.dart';

class NearbyDriversList{

  static  List<NearbyDriver>drivers = [];
  
  static void deleteDriver(String key){
    
    int index = drivers.indexWhere((element) => element.key == key);
    drivers.removeAt(index);
    
  }
  
  static void updateDriverLocation(NearbyDriver driver){

    int index = drivers.indexWhere((element) => element.key == driver.key);
    drivers[index].latitude = driver.latitude;
    drivers[index].longitude = driver.longitude;
    
  }



}