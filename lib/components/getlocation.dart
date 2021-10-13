//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Defines the main theme color.
// final MaterialColor themeMaterialColor =
//     BaseflowPluginExample.createMaterialColor(
//         const Color.fromRGBO(48, 49, 60, 1));

void main() {
  runApp(GeolocatorWidget());
}

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {
  /// Utility method to create a page with the Baseflow templating.

  @override
  _GeolocatorWidgetState createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  
  late  Locationdetails locationdetails=Locationdetails("region", "subregion", "city");
  // StreamSubscription<ServiceStatus>? _locationServiceStatusSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Get location details")),
      body: Center(
          child:  Card(
                  child: ListTile(
                    tileColor: Colors.lightBlue,
                    subtitle: Text(
                      locationdetails.region,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    title: Text(
                      locationdetails.city+"  "+locationdetails.subregion
                     ,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
           
        ),
      floatingActionButton: Stack(
        children: <Widget>[
     
      
          Positioned(
            bottom: 15.0,
            right: 3.0,
            child: FloatingActionButton.extended(
                onPressed: () async {
                   await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.best)
                      .then((value) async {
                    await GeocodingPlatform.instance.placemarkFromCoordinates(
                            value.latitude, value.longitude)
                        .then((value2) {
                           setState(
                    () {
                    locationdetails=Locationdetails(value2.first.locality!, value2.first.subLocality!, value2.first.street!)
                          ;
                          }
                  );
                      return value2;
                    });
                  });

                 
                },
                label: Text("Currently at")),
          ),
         
        ],
      ),
    );
  }

 
 

  @override
  void dispose() {
   

    super.dispose();
  }
}



class Locationdetails {
  Locationdetails(this.region, this.subregion, this.city);
  final String region;
  final String subregion;
  final String city;
}
