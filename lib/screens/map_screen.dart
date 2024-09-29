// ignore_for_file: unnecessary_import, camel_case_types, prefer_final_fields, prefer_typing_uninitialized_variables, avoid_print, non_constant_identifier_names, unused_import, unused_field, unused_local_variable, depend_on_referenced_packages, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:clippy_flutter/bevel.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:prozigzag_driver/Common_Code/common_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../api_model/passanger_details_api_model.dart';
import '../config/config.dart';
import 'package:intl/intl.dart';

class demo_map_screen extends StatefulWidget {
  const demo_map_screen({super.key});

  @override
  State<demo_map_screen> createState() => _demo_map_screenState();
}

class _demo_map_screenState extends State<demo_map_screen> {

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _kGooglePlex;

  var userData;
  var busiddata;
  var tripdata;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      busiddata = jsonDecode(prefs.getString("busid")!);
      tripdata = jsonDecode(prefs.getString("tridetails")!);

      passanget_detaisl().then((value) {
      // Future.delayed(Duration(seconds: 5),() {
        getDirections();
      // },)  ;

      });

    });
  }

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  List<LatLng> latlng = [];
  List<LatLng> A = [];

  bool isloading = true;

  Passangerdetaiss? data1;
  Future passanget_detaisl() async {

    Map body = {
      'driver_id' : userData["id"],
      'bus_id': busiddata
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/Pessenger_details.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){

          data1 = passangerdetaissFromJson(response.body);

          _kGooglePlex = CameraPosition(
              target: LatLng(double.parse(data1!.totalPointList.first.pointLats), double.parse(data1!.totalPointList.first.pointLongs)),
              zoom: 10
          );
          setState(() {
            isloading = false;
          });
      try{
       for(int a= 0; a < data1!.totalPointList.length; a++){

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(double.parse(data1!.totalPointList[a].pointLats), double.parse(data1!.totalPointList[a].pointLongs)),
      PointLatLng(double.parse(data1!.totalPointList[(data1!.totalPointList.length -1 == a) ? a : a+1].pointLats), double.parse(data1!.totalPointList[(data1!.totalPointList.length -1 == a) ? a : a+1].pointLongs)),
      travelMode: TravelMode.driving,
    );

    for (var element in result.points) {
      A.add(LatLng(element.latitude, element.longitude));
    }
    setState(() {

    });

    getmarkers(a);
  }
       return data1;
       }catch(a){
         print(a);
       }

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlocledata();

    // passanget_detaisl();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  List<LatLng> pointss = [];
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyCRF9Q1ttrleh04hqRlP_CqsFCPU815jJk";
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng startLocation1 = const LatLng(21.1702, 72.8311);
  LatLng endLocation1 = const LatLng(27.0238, 74.2179);

  List B = [];
  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    // B.add(startLocation);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation1.latitude, startLocation1.longitude),
      PointLatLng(endLocation1.latitude, endLocation1.longitude),
      travelMode: TravelMode.driving,
    );

    print(B.length);
    // if(B.length == 7){
      if (A.isNotEmpty) {
        for (var point in A) {
          // A.add(LatLng(point.latitude, point.longitude));
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(" 0 0 000000  0  0 00 0 0 0 0 0 0 0 0 $A");
      }
    addPolyLine(polylineCoordinates);
    // }

  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly12");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading ? const Center(child: CircularProgressIndicator()) :  Stack(
        children: [
          SizedBox(
            height: Get.size.height,
            child: GoogleMap(
            markers: _markers,
              onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _customInfoWindowController.googleMapController = controller;
              },
              onTap: (postition) {
              },
              polylines: Set<Polyline>.of(polylines.values),
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex!,
              mapType: MapType.normal,
            ),
          ),
          Positioned(
            top: 35,
            left: 10,
            child: Container(
              height: 45,
              width: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.4),
              ),
              child: BackButton(
                onPressed: () {
                  Get.back();
                },
                color: Colors.white,
              ),
            ),
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 80,
            width: 150,
            // offset: 35,
          ),
        ],
      ),
    );
  }

  getmarkers(i) async {
    final Uint8List markIcon = await getImages("assets/Pin.png", 80);

    _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(
            double.parse(data1!.totalPointList[i].pointLats ?? "0"), // ignore: dead_null_aware_expression
            double.parse(data1!.totalPointList[i].pointLongs ?? ""), // ignore: dead_null_aware_expression
          ),
          infoWindow: InfoWindow(
            // anchor: Offset(0, -20),
            title: '(${i+1})-${data1!.totalPointList[i].dropTitle}',
            snippet: '${data1!.totalPointList[i].dropAddress}-(${convertTimeTo12HourFormat(data1!.totalPointList[i].dropTime)})',
          ),

          icon: BitmapDescriptor.fromBytes(markIcon),
          // position of marker
        ));
  }



  String convertTimeTo12HourFormat(String time24Hour) {
    // Parse the input time in 24-hour format
    final inputFormat = DateFormat('HH:mm:ss');
    final inputTime = inputFormat.parse(time24Hour);

    // Format the time in 12-hour format
    final outputFormat = DateFormat('h:mm a');
    final formattedTime = outputFormat.format(inputTime);

    return formattedTime;
  }

}



