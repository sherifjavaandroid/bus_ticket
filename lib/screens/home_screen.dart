// ignore_for_file: camel_case_types, unnecessary_import, avoid_print, sized_box_for_whitespace, prefer_typing_uninitialized_variables, depend_on_referenced_packages, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, unnecessary_new

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/screens/trip_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_model/trip_details_api_model.dart';
import '../config/config.dart';
import '../config/dark_light.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';





Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Live Tracking',
      initialNotificationContent: 'Start',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  String title = preferences.getString("BusTitle") ?? "0000";
  String number = preferences.getString("BusNumber") ?? "0000";
  print(" 00 0 0 0 0 0 ${title}");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: title,
          content: number,
        );
      }
    }

    /// you can see this log in logcat
    // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}



String? busttle;
String? busno;



class Home_screen extends StatefulWidget {
  const Home_screen({super.key});

  @override
  State<Home_screen> createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {

  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlocledata();
    getUserCurrentLocation().then((value) {
      startLocation = LatLng(value.latitude, value.longitude);
      setState(() {});
    },);
  }

  late TripDetails data;

  LatLng startLocation = const LatLng(21.1702, 72.8311);
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future tripdetails(String uid) async {

    Map body = {
      'driver_id' : uid,
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/Trip_details.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
          data = tripDetailsFromJson(response.body.toString());
          fun();
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("busid", jsonEncode(data.tripDetails.busId));
        prefs.setString("tridetails", jsonEncode(data.tripDetails));
        prefs.setString("statussintogale", jsonEncode(statuss));

        print(data);

        return data;
      }else{
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  // Sharepreferance data set

  var userData;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      tripdetails(userData["id"]);

      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ID +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ${userData["id"]}');
    });
  }

  bool isloading = true;
  bool? statuss;
  var fields;

  fun(){
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('driver');
    collectionReference.doc(data.tripDetails.busId).get().then((value) {

      fields = value.data();
      print("+++++fieldsfieldsfieldsfieldsfields:---++++  ${fields}");
      print("+++++fieldsfieldsfieldsfieldsfields:++++---++++  ${fields['ischeck']}");
      statuss = fields['ischeck'];

      if(statuss == true){
        getlatlong();
      }else{
        locationSubscription?.cancel();
        print('+++++++++++ Hi else condition +++++++++++');
      }

     setState(() {
       isloading = false;
     });

    });
  }

  getlatlong(){
    CollectionReference collRef = FirebaseFirestore.instance.collection('driver');
    if(statuss == true){
      locationSubscription = location.onLocationChanged.listen((cLoc) {
        print("++++++cLoc+++++cLoc+++++cLoc+++++  ------------ ++${cLoc}");
        collRef.doc(data.tripDetails.busId).update({
          'livelatitude': cLoc.latitude,
          'livelongitude': cLoc.longitude,
        });
      });
    }else{
      locationSubscription?.cancel();
      print('+++++++++++ Hi else condition 1 +++++++++++');
    }
  }

  Location location = new Location();
  StreamSubscription<LocationData>? locationSubscription;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: isloading ? null : AppBar(
       backgroundColor: notifier.appbarcolore,
       automaticallyImplyLeading: false,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/Ellipse.png'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10,bottom: 10),
            child: SizedBox(
              height: 35,
              child: LiteRollingSwitch(
                width: 110,
                value: statuss!,
                textOn: 'ONLINE',
                textOff: 'OFFLINE',
                colorOn: notifier.theamcolorelight,
                colorOff: Colors.redAccent,
                iconOn: Icons.bus_alert_sharp,
                iconOff: Icons.bus_alert_sharp,
                textSize: 13,
                textOffColor: Colors.white,
                textOnColor: Colors.white,
                onChanged: (bool state) async {

                  print('Current State of SWITCH IS: $state');

                  final service = FlutterBackgroundService();
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  if(statuss == true){
                    setState(() {
                      service.invoke("stopService");
                    });
                    print('+++++++++++ Hi else intilize condition 2 +++++++++++');
                  }else{
                    // locationSubscription?.cancel();
                    setState(() {
                      busttle = data.tripDetails.busTitle;
                      busno = data.tripDetails.busNo;
                      print('+++++++++ busttle = data.tripDetails.busTitle  ${busttle}');
                    });

                    await preferences.setString("BusTitle", "$busttle").then((value) async {
                      await preferences.setString("BusNumber", "$busno").then((value) {
                        initializeService();
                      });
                    });
                  }

                  CollectionReference collRef = FirebaseFirestore.instance.collection('driver');


                  statuss = state;
                  setState(() {
                  });

                  location = Location();

                  collRef.doc(data.tripDetails.busId).set({
                    'bus_id': data.tripDetails.busId,
                    'driver_id': userData["id"],
                    'ischeck': state,
                    'latitude': startLocation.latitude,
                    'longitude': startLocation.longitude,
                    'livelatitude': startLocation.latitude,
                    'livelongitude': startLocation.longitude,
                  });

                  print(statuss);

                  if(statuss == true){
                    getlatlong();
                  }else{
                    locationSubscription?.cancel();
                    print('+++++++++++ Hi else condition 2 +++++++++++');
                  }

                },
                onTap: (){},
                onDoubleTap: (){},
                onSwipe: (){},
              ),
            ),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: isloading ?  Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) :  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Text('My Today`s Trips',style: TextStyle(color: notifier.textColor,fontSize: 20,fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {

                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) =>  const trip_details(dummystatus: false),));
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              color: notifier.theamcolorelight,
                                              borderRadius: BorderRadius.circular(65),
                                              image: DecorationImage(image: NetworkImage('${config().baseUrl2}/${data.tripDetails.busImg}'),fit: BoxFit.fill))
                                      ),
                                      const SizedBox(width: 10,),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data.tripDetails.busTitle,style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                            const SizedBox(height: 5,),
                                            Row(
                                              children: [
                                                if(data.tripDetails.busAc == '1')  Flexible(child: Text('AC Seater',style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                if(data.tripDetails.isSleeper == '1')  Flexible(child: Text('Non Ac / Sleeper',style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                                const SizedBox(width: 5,),
                                                Container(
                                                    height: 22,
                                                    width: 65,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: notifier.seatbordercolore),
                                                        color: notifier.seatcontainere,
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    child: Center(child: Padding(
                                                      padding: const EdgeInsets.only(top: 3),
                                                      child: Text('${data.tripDetails.totlSeat} Seats',style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.seattextcolore),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                    ))
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4,),
                                      Column(
                                        children: [
                                          Text('${data.currency} ${data.tripDetails.ticketPrice}',style: TextStyle(color: notifier.theamcolorelight,fontSize: 15,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(data.tripDetails.boardingCity,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                              const SizedBox(height: 8,),
                                              Text(convertTimeTo12HourFormat(data.tripDetails.busPicktime),style:   TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight,fontSize: 12),overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 8,),
                                              Text(data.tripDetails.pickDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 8,),
                                              // Text('Seat : ${data.busData[index].totlSeat}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Column(
                                        children: [
                                          Image(image: const AssetImage('assets/Auto Layout Horizontal.png'),height: 50,width: 120,color: notifier.theamcolorelight),
                                          Text(data.tripDetails.differencePickDrop,style: TextStyle(fontSize: 12,color: notifier.textColor)),
                                        ],
                                      ),
                                      const SizedBox(width: 5,),
                                      Flexible(
                                        child: SizedBox(
                                          width: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(data.tripDetails.dropCity,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                              const SizedBox(height: 8,),
                                              Text(convertTimeTo12HourFormat(data.tripDetails.busDroptime),style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight ,fontSize: 12),overflow: TextOverflow.ellipsis,),
                                              const SizedBox(height: 8,),
                                              Text(data.tripDetails.dropDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 8,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

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

