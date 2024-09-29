// ignore_for_file: unnecessary_import, camel_case_types, sort_child_properties_last, avoid_print, non_constant_identifier_names, prefer_typing_uninitialized_variables, unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/common_code/common_button.dart';
import 'package:prozigzag_driver/screens/home_screen.dart';
import 'package:prozigzag_driver/screens/qr_code_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_model/passanger_details_api_model.dart';
import '../api_model/report_api_model.dart';
import '../config/config.dart';
import '../config/dark_light.dart';
import 'package:http/http.dart' as http;

import 'map_screen.dart';

class trip_details extends StatefulWidget {
  final bool dummystatus;

  const trip_details({super.key, required this.dummystatus});

  @override
  State<trip_details> createState() => _trip_detailsState();
}

class _trip_detailsState extends State<trip_details> {

  // late final TabController _tabController;

  ColorNotifier notifier = ColorNotifier();

  List text = [
    'School',
    'Murugankurichi',
    'Vannarpettai',
    'Junction',
    'Stipuram',
    'Town',
    'Murugankurichi',
    'Vannarpettai',
  ];

  bool isstart = false;

  _makingPhoneCall(String number) async {
    var url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlocledata();
  }

  Passangerdetaiss? data1;
  bool isloading = true;

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

        setState(() {
          data1 = passangerdetaissFromJson(response.body);
          isloading = false;

        });

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  var userData;
  var busiddata;
  var tripdata;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      busiddata = jsonDecode(prefs.getString("busid")!);
      tripdata = jsonDecode(prefs.getString("tridetails")!);
      passanget_detaisl();
    });
  }

  TextEditingController commentcontroller = TextEditingController();

  late Report data;

  Future reportdetails() async {

    Map body = {
      "bus_id": busiddata,
      "driver_id": userData["id"],
      "comment": commentcontroller.text
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/report.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
          data = reportFromJson(response.body.toString());
          // isloading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data.responseMsg),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
          );
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

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: notifier.background,
        // backgroundColor: Colors.red,
        floatingActionButton: widget.dummystatus == true ?  const SizedBox():  FloatingActionButton(
          backgroundColor: notifier.theamcolorelight,
          tooltip: 'Increment',
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QrViewScreen(),));
          },
          child: const Icon(Icons.qr_code_scanner_sharp, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: notifier.appbarcolore,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          title: const Text('TRIP DETAILS',style: TextStyle(color: Colors.white,fontSize: 18)),
        ),
        body: isloading ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) : Column(
          children: [
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bus No',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 12)),
                          const SizedBox(height: 3,),
                          Text('${tripdata['bus_no']}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 35,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pick and Drop Time',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 12)),
                          const SizedBox(height: 3,),
                          Row(
                            children: [
                              Text('${convertTimeTo12HourFormat(tripdata['bus_picktime'])}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                              Text(' - ',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                              Text('${convertTimeTo12HourFormat(tripdata['bus_droptime'])}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    widget.dummystatus == true ?  const SizedBox(): ElevatedButton(
                        style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero),backgroundColor: MaterialStatePropertyAll(Colors.orange),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
                        onPressed: (){
                          Get.bottomSheet(
                              isDismissible: false,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                              ),
                              Container(
                                height: 222,
                                // width: 200,
                                decoration: BoxDecoration(
                                    color: notifier.containercoloreproper,
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: commentcontroller,
                                        maxLines: 5,
                                        style: TextStyle(color: notifier.textColor),
                                        decoration:  InputDecoration(
                                            // contentPadding: const EdgeInsets.only(left: 10,top: 10),
                                            focusColor: Colors.red,
                                            border: InputBorder.none,
                                            hintText: 'Enter Your Reason',
                                            hintStyle: TextStyle(color: notifier.textColor),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                                              // border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                              borderRadius: const BorderRadius.all(Radius.circular(10))
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: notifier.theamcolorelight),
                                              // border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                              borderRadius: const BorderRadius.all(Radius.circular(10))
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      CommonButton(containcolore: notifier.theamcolorelight, onPressed1: (){
                                        reportdetails();
                                        Get.back();
                                      },context: context,txt1: 'Submit'),
                                      const SizedBox(height: 10,)
                                    ],
                                  ),
                                ),
                              )
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.report_problem_outlined,size: 17),
                              SizedBox(width: 2,),
                              Text('Report Incident'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      widget.dummystatus == true ?  const SizedBox():   ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          backgroundColor: MaterialStateProperty.all(notifier.theamcolorelight),
                          shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  const demo_map_screen(),));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pin_drop_outlined,size: 17),
                              SizedBox(width: 2,),
                              Text('Map'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {

                        showModalBottomSheet(
                          isScrollControlled: true,
                          isDismissible: false,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState)  {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.topCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                                        child: SizedBox(
                                          height: 650,
                                          child: Scaffold(
                                            backgroundColor: notifier.containercoloreproper,
                                            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                                            floatingActionButton: Padding(
                                              padding:const EdgeInsets.only(bottom: 10,left: 10,right: 10),
                                              child: Container(
                                                  height: 42,
                                                  width: MediaQuery.of(context).size.width,
                                                  decoration: BoxDecoration(
                                                    color: notifier.theamcolorelight,
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(notifier.theamcolorelight),
                                                      shape: MaterialStateProperty.all(
                                                        const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Center(
                                                      child: RichText(text:  TextSpan(
                                                          children: [
                                                            TextSpan(text: 'Close'.tr,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                                          ]
                                                      )),
                                                    ),
                                                  )
                                              ),
                                            ),
                                            body: Container(
                                              // height: 700,
                                              width: Get.width,
                                              decoration: BoxDecoration(
                                                  color: notifier.containercoloreproper,
                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(0),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 50,),
                                                      Text('View Route',style: TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 20),),
                                                      const SizedBox(height: 20,),
                                                      Text('Bus will stop at the following',style: TextStyle(color: notifier.textColor,fontSize: 15),),
                                                      Text('locations',style: TextStyle(color: notifier.textColor,fontSize: 15),),
                                                      const SizedBox(height: 10,),
                                                      ListView.separated(
                                                          separatorBuilder: (context, index) {
                                                            return const SizedBox(width:  10);
                                                          },
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          scrollDirection: Axis.vertical,
                                                          itemCount: data1!.totalPointList.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return SizedBox(
                                                              height: 60,
                                                              child: TimelineTile(
                                                                alignment: TimelineAlign.manual,
                                                                lineXY:  0.13,
                                                                isFirst: index == 0 ? true : false,
                                                                isLast: index == text.length - 1 ? true : false,
                                                                startChild:  Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(convertTimeTo12HourFormat(data1!.totalPointList[index].dropTime).split(" ").first,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                                                    const SizedBox(height: 3,),
                                                                    Text(convertTimeTo12HourFormat(data1!.totalPointList[index].dropTime).split(" ").last,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                                                  ],
                                                                ),
                                                                endChild:  Padding(
                                                                  padding: const EdgeInsets.only(left: 20,right: 10,top: 15),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text('${data1?.totalPointList[index].dropTitle}',style: TextStyle(color: notifier.textColor)),
                                                                      Text('${data1?.totalPointList[index].dropAddress}',style: TextStyle(color: notifier.textColor),maxLines: 1,),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // isFirst: true,
                                                                beforeLineStyle: LineStyle(color: Colors.grey.withOpacity(0.4),thickness: 2),
                                                                indicatorStyle: index == 0 ?  IndicatorStyle(
                                                                  // height: 15,
                                                                  // width: 15,
                                                                    color: notifier.theamcolorelight,
                                                                    indicator: Icon(Icons.school_outlined,color: notifier.theamcolorelight,)
                                                                ) : IndicatorStyle(
                                                                    height: 10,
                                                                    width: 10,
                                                                    color: notifier.theamcolorelight,
                                                                    indicator: Container(
                                                                      decoration: BoxDecoration(
                                                                        color:  notifier.theamcolorelight,
                                                                        borderRadius: const BorderRadius.all(Radius.circular(65)),

                                                                      ),)
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                      // Padding(
                                                      //   padding: const EdgeInsets.only(left: 15,right: 15,bottom: 25),
                                                      //   child: CommonButton(containcolore: notifier.theamcolorelight, context: context,txt1: 'Close',onPressed1: (){}),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -30,
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: notifier.theamcolorelight,
                                              border: Border.all(color: Colors.white,width: 2)
                                          ),
                                          child: const Center(child: Icon(Icons.pin_drop_outlined,color: Colors.white,)),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            );
                          },
                        );

                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 30,
                            // width: 80,
                            decoration: BoxDecoration(
                                color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:  Center(child: Text('${data1?.totalPoint}',style: const TextStyle(color: Colors.white),)),
                          ),
                          const SizedBox(height: 5,),
                          Text('Total(Route)',style: TextStyle(color: notifier.textColor,fontSize: 10),maxLines: 1,),

                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          // width: 120,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text('${tripdata['totl_seat']}',style: const TextStyle(color: Colors.white),)),
                        ),
                        const SizedBox(height: 5,),
                        Text('TOTAL SEAT',style: TextStyle(color: notifier.textColor,fontSize: 10),maxLines: 1,),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          // width: 80,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Center(child: Text('${tripdata['left_seat']}',style: const TextStyle(color: Colors.white),)),
                        ),
                        const SizedBox(height: 5,),
                        Text('LEFT SEAT',style: TextStyle(color: notifier.textColor,fontSize: 10),maxLines: 1,),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          // width: 80,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Center(child: Text('${tripdata['ticket_price']}',style: const TextStyle(color: Colors.white),)),
                        ),
                        const SizedBox(height: 5,),
                        Text('Ticket Price',style: TextStyle(color: notifier.textColor,fontSize: 10),maxLines: 1,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  TabBar(
                    onTap: (value) {
                    },
                    // controller: _tabController,
                    indicatorColor: notifier.theamcolorelight,
                    labelColor: notifier.textColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    // unselectedLabelColor: Colors.grey,
                    tabs: <Widget>[
                      Tab(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Boarding Point',style: TextStyle(color: notifier.textColor,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      )),
                      Tab(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Dropping Point',style: TextStyle(color: notifier.textColor,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],
                      )),
                    ],
                  ),



                  Expanded(
                    child: TabBarView(
                      // controller: _tabController,
                      children: <Widget>[
                        ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 10);
                            },
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: data1!.boardingArr.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TimelineTile(
                                alignment: TimelineAlign.manual,
                                lineXY:  0.14,
                                isFirst: index == 0 ? true : false,
                                // isLast: data1!.boardingArr.length == -1 ? true : false,
                                startChild:  Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(convertTimeTo12HourFormat(data1!.boardingArr[index].boardTime).split(" ").first,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                    const SizedBox(height: 3,),
                                    Text(convertTimeTo12HourFormat(data1!.boardingArr[index].boardTime).split(" ").last,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                                endChild: Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                                  child: Container(
                                    // height: 100,
                                    decoration: BoxDecoration(
                                      color: notifier.containercolore,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${data1?.boardingArr[index].boardTitle}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(color: notifier.textColor)),
                                          const SizedBox(height: 5,),
                                          Text('${data1?.boardingArr[index].boardAddress}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(color: notifier.textColor)),
                                          const SizedBox(height: 10,),

                                          for(int a = 0; a<data1!.boardingArr[index].customerData.length; a++) Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Container(
                                              // height: 50,
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  color: notifier.background,
                                                  borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Contact Details',style: TextStyle(color: notifier.textColor,fontSize: 14,fontWeight: FontWeight.bold),),
                                                        const Spacer(),
                                                        InkWell(
                                                            onTap: ()  {
                                                              _makingPhoneCall(data1!.boardingArr[index].customerData[a].custMobile);
                                                            },
                                                            child: const CircleAvatar(child: Icon(Icons.call,color: Colors.white,size: 12),backgroundColor: Colors.green,radius: 10)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text('Name',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                        const Spacer(),
                                                        Text('${data1?.boardingArr[index].customerData[a].custName}',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text('Number',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                        const Spacer(),
                                                        Text('${data1?.boardingArr[index].customerData[a].custMobile}',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    for(int b = 0; b<data1!.boardingArr[index].customerData[a].pessengerData.length; b++)
                                                      if(data1!.boardingArr[index].customerData.isEmpty) const SizedBox() else
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: notifier.backgroundgray,
                                                              border: Border.all(color: notifier.backgroundgray),
                                                              borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: ListTileTheme(
                                                            contentPadding: EdgeInsets.zero,
                                                            minVerticalPadding: 0,
                                                            dense: true,
                                                            child: ExpansionTile(
                                                              tilePadding: const EdgeInsets.only(left: 10,right: 10),
                                                              backgroundColor: notifier.background,
                                                              shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: const BorderSide(color: Colors.transparent)),
                                                              collapsedIconColor: notifier.textColor,
                                                              iconColor: notifier.textColor,
                                                              textColor: const Color(0xff7D2AFF),
                                                              // collapsedTextColor: Color(0xff7D2AFF),
                                                              // backgroundColor: Color(0xff7D2AFF),
                                                              title: Text('${data1?.boardingArr[index].customerData[a].pessengerData[b].name}',style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.textColor)),
                                                              children:  <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Text('Age and Gender',style: TextStyle(color: notifier.textColor)),
                                                                          const Spacer(),
                                                                          Text('${data1?.boardingArr[index].customerData[a].pessengerData[b].age} (${data1?.boardingArr[index].customerData[a].pessengerData[b].gender})',style: TextStyle(color: notifier.textColor))
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 6,),
                                                                      Row(
                                                                        children: [
                                                                          Text('Seat No',style: TextStyle(color: notifier.textColor)),
                                                                          const Spacer(),
                                                                          Text('${data1?.boardingArr[index].customerData[a].pessengerData[b].seatNo}',style: TextStyle(color: notifier.textColor))
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 10,),
                                                                      data1!.boardingArr[index].customerData[a].pessengerData[b].checkIn == "0" ?  const SizedBox()  : data1!.boardingArr[index].customerData[a].pessengerData[b].checkIn == "1" ? Container(
                                                                        // height: 40,
                                                                        decoration: BoxDecoration(
                                                                            color: notifier.theamcolorelight,
                                                                            borderRadius: BorderRadius.circular(10)
                                                                        ),
                                                                        child:  const Padding(
                                                                          padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 8.0,bottom: 8.0),
                                                                          child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Image(image: AssetImage('assets/patch-check-fill.png'),height: 20,width: 20,),
                                                                              SizedBox(width: 5,),
                                                                              Flexible(child: Text('Boarded',style: TextStyle(color: Colors.white),maxLines: 3,overflow: TextOverflow.ellipsis)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ) : data1!.boardingArr[index].customerData[a].pessengerData[b].checkIn == "2" ? Container(
                                                                        // height: 40,
                                                                        decoration: BoxDecoration(
                                                                          color: const Color(0xffE5646C),
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                        child:  Padding(
                                                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 8.0,bottom: 8.0),
                                                                          child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              const Image(image: AssetImage('assets/question-circle-fill.png'),height: 20,width: 20,),
                                                                              const SizedBox(width: 5,),
                                                                              Flexible(child: Text('Cancel Reason: ${data1?.boardingArr[index].customerData[a].pessengerData[b].cancleReason}',style: const TextStyle(color: Colors.white),maxLines: 3,overflow: TextOverflow.ellipsis)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ) : const SizedBox()
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // isFirst: true,
                                beforeLineStyle: LineStyle(color: Colors.grey.withOpacity(0.4),thickness: 2),
                                indicatorStyle: IndicatorStyle(
                                    height: 15,
                                    width: 15,
                                    color: notifier.theamcolorelight,
                                    indicator: Container(
                                      decoration: BoxDecoration(
                                          color:  Colors.white,
                                          borderRadius: const BorderRadius.all(Radius.circular(65)),
                                          border: Border.all(color: notifier.theamcolorelight,width: 3)
                                      ),)
                                ),
                              );
                            }),

                        ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(width:  10);
                            },
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: data1!.droppoint.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TimelineTile(
                                alignment: TimelineAlign.manual,
                                lineXY:  0.14,
                                isFirst: index == 0 ? true : false,
                                startChild:  Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(convertTimeTo12HourFormat(data1!.droppoint[index].dropTime).split(" ").first,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                    const SizedBox(height: 3,),
                                    Text(convertTimeTo12HourFormat(data1!.droppoint[index].dropTime).split(" ").last,style: TextStyle(fontSize: 10,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                                endChild: Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                                  child: Container(
                                    // height: 100,
                                    decoration: BoxDecoration(
                                      color: notifier.containercolore,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${data1?.droppoint[index].dropTitle}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(color: notifier.textColor)),
                                          const SizedBox(height: 5,),
                                          Text('${data1?.droppoint[index].dropAddress}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(color: notifier.textColor)),
                                          const SizedBox(height: 10,),

                                          for(int a = 0; a<data1!.droppoint[index].customerData!.length; a++)    Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Container(
                                              // height: 50,
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                color: notifier.background  ,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Contact Details',style: TextStyle(color: notifier.textColor,fontSize: 14,fontWeight: FontWeight.bold),),
                                                        const Spacer(),
                                                        InkWell(
                                                            onTap: ()  {

                                                              _makingPhoneCall(data1!.droppoint[index].customerData![a].custMobile);

                                                            },
                                                            child: const CircleAvatar(child: Icon(Icons.call,color: Colors.white,size: 12),backgroundColor: Colors.green,radius: 10)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text('Name',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                        const Spacer(),
                                                        Text('${data1!.droppoint[index].customerData?[a].custName}',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text('Number',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                        const Spacer(),
                                                        Text('${data1!.droppoint[index].customerData?[a].custMobile}',style: TextStyle(color: notifier.textColor,fontSize: 12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    for(int b = 0; b<data1!.droppoint[index].customerData![a].pessengerData.length; b++)
                                                      if(data1!.droppoint[index].customerData!.isEmpty) const SizedBox() else
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: notifier.backgroundgray,
                                                                border: Border.all(color: notifier.backgroundgray),
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: ListTileTheme(
                                                              contentPadding: EdgeInsets.zero,
                                                              minVerticalPadding: 0,
                                                              dense: true,
                                                              child: ExpansionTile(
                                                                tilePadding: const EdgeInsets.only(left: 10,right: 10),
                                                                backgroundColor: notifier.background,
                                                                shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: const BorderSide(color: Colors.transparent)),
                                                                collapsedIconColor: notifier.textColor,
                                                                iconColor: notifier.textColor,
                                                                textColor: const Color(0xff7D2AFF),

                                                                title: Text('${data1!.droppoint[index].customerData?[a].pessengerData[b].name}',style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.textColor)),
                                                                children:  <Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text('Age and Gender',style: TextStyle(color: notifier.textColor)),
                                                                            const Spacer(),
                                                                            Text('${data1?.droppoint[index].customerData?[a].pessengerData[b].age} (${data1!.droppoint[index].customerData?[a].pessengerData[b].gender})',style: TextStyle(color: notifier.textColor))
                                                                          ],
                                                                        ),
                                                                        const SizedBox(height: 6,),
                                                                        Row(
                                                                          children: [
                                                                            Text('Seat No',style: TextStyle(color: notifier.textColor)),
                                                                            const Spacer(),
                                                                            Text('${data1!.droppoint[index].customerData?[a].pessengerData[b].seatNo}',style: TextStyle(color: notifier.textColor))
                                                                          ],
                                                                        ),

                                                                        const SizedBox(height: 10,),

                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // isFirst: true,
                                beforeLineStyle: LineStyle(color: Colors.grey.withOpacity(0.4),thickness: 2),
                                indicatorStyle: IndicatorStyle(
                                    height: 15,
                                    width: 15,
                                    color: notifier.theamcolorelight,
                                    indicator: Container(
                                      decoration: BoxDecoration(
                                          color:  Colors.white,
                                          borderRadius: const BorderRadius.all(Radius.circular(65)),
                                          border: Border.all(color: notifier.theamcolorelight,width: 3)
                                      ),)
                                ),
                              );
                            }),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),

          ],
        ),
      ),
    );
  }
}
