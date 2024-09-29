// ignore_for_file: unused_import, unnecessary_import, camel_case_types, sized_box_for_whitespace, avoid_print, depend_on_referenced_packages, prefer_typing_uninitialized_variables, unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/screens/trip_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_model/trip_hestory_api_model.dart';
import '../config/config.dart';
import '../config/dark_light.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Hostory_screen extends StatefulWidget {
  const Hostory_screen({super.key});

  @override
  State<Hostory_screen> createState() => _Hostory_screenState();
}

class _Hostory_screenState extends State<Hostory_screen> {

  ColorNotifier notifier = ColorNotifier();
  bool isloading = true;
  late Triphistory data;

  Future triphistoryapi(String uid) async {

    Map body = {
      'driver_id' : uid,
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/trip_history.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
          data = triphistoryFromJson(response.body.toString());
          isloading = false;
        });


        print(data);

        return data;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  var userData;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      triphistoryapi(userData["id"]);
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ID +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ${userData["id"]}');
    });
  }

  @override
  void initState() {
    getlocledata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.appbarcolore,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Center(child: Text('My History',style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body:  isloading ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) :  Padding(
        padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                data.tripHistory.isEmpty ? const SizedBox() : Text('My History',style: TextStyle(color: notifier.textColor,fontSize: 20,fontWeight: FontWeight.bold)),
                const Spacer(),
                // const Text('SEE ALL',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15,),
            data.tripHistory.isEmpty ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(image: AssetImage('assets/amyticket.png'),height: 70,width: 70,),
                  const SizedBox(height: 15,),
                  Text('No booking found'.tr,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: notifier.textColor),),
                  const SizedBox(height: 25,),
                  Text('You dont`t have any booking records!'.tr,style: const TextStyle(color: Colors.grey),),
                ],
              ),
            ) : Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 0,height: 10,);
                  },
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: data.tripHistory.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const trip_details(dummystatus: true),));
                      },
                      child: Container(
                        // height: 255,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            // const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 15,right: 15),
                              child: Container(
                                height: 40,
                                // color: Colors.red,
                                child: Row(
                                  children: [
                                    // SizedBox(width: 10,),
                                    Expanded(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        horizontalTitleGap: -6,
                                        isThreeLine: true,
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        leading: Image(image: const AssetImage('assets/credit-card.png'),color: notifier.theamcolorelight,height: 25,width: 25,),
                                        title: Text('${data.tripHistory[index].ticketPrice}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 11)),
                                        subtitle: Text('Ticket Price',style: TextStyle(color: notifier.theamcolorelight,fontSize: 12)),
                                      ),
                                    ),
                                    // Spacer(),
                                    Expanded(
                                      child: ListTile(
                                        horizontalTitleGap: -6,
                                        isThreeLine: true,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        leading: Image(image: const AssetImage('assets/bus.png'),color: notifier.theamcolorelight,height: 25,width: 25,),
                                        title: Text('${data.tripHistory[index].busNo}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 11)),
                                        subtitle: Text('Bus No',style: TextStyle(color: notifier.theamcolorelight,fontSize: 12)),
                                      ),
                                    ),
                                    // Spacer(),
                                    Expanded(
                                      child: ListTile(
                                        horizontalTitleGap: -6,
                                        isThreeLine: true,
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        leading: Image(image: const AssetImage('assets/b1.png'),color: notifier.theamcolorelight,height: 25,width: 25,),
                                        title: Text('${data.tripHistory[index].totlSeat}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 11)),
                                        subtitle: Text('Total Seat',style: TextStyle(color: notifier.theamcolorelight,fontSize: 12)),
                                      ),
                                    ),
                                    // SizedBox(width: 10,),
                                  ],
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey.withOpacity(0.4)),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Image(image: const AssetImage('assets/timeline.png'),height: 120,width: 20,color: notifier.theamcolorelight),
                                  const SizedBox(width: 10,),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${data.tripHistory[index].boardingCity}',overflow: TextOverflow.ellipsis,maxLines: 3,style: TextStyle(color: notifier.textColor,fontSize: 17,fontWeight: FontWeight.bold)),
                                            Text('${convertTimeTo12HourFormat(data.tripHistory[index].busPicktime)}',style: TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                        const SizedBox(height: 28,),
                                        Container(
                                          height: 30,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(color: Colors.grey.withOpacity(0.4))
                                          ),
                                          child:  Center(
                                            child: Text('${data.tripHistory[index].differencePickDrop} distance',style: const TextStyle(color: Colors.grey)),
                                          ),
                                        ),
                                        const SizedBox(height: 28,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${data.tripHistory[index].dropCity}',overflow: TextOverflow.ellipsis,maxLines: 3,style: TextStyle(color: notifier.textColor,fontSize: 17,fontWeight: FontWeight.bold)),
                                            Text('${convertTimeTo12HourFormat(data.tripHistory[index].busDroptime)}',style: TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),

          ],
        ),
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

// km -> ticket price
// hours -> bus number
// passanger - > totl_seat

// container ni under -> Difference_pick_drop