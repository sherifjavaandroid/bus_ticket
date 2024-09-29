// ignore_for_file: unnecessary_this, prefer_interpolation_to_compose_strings, avoid_print, sort_child_properties_last, prefer_const_constructors, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, non_constant_identifier_names, unused_field, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prozigzag_driver/common_code/common_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../api_model/scan_qr_code_api_model.dart';
import '../config/config.dart';
import '../config/homecontroller.dart';
import 'bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

class QrViewScreen extends StatefulWidget {
  const QrViewScreen({super.key});

  @override
  State<QrViewScreen> createState() => _QrViewScreenState();
}

class _QrViewScreenState extends State<QrViewScreen> {
  // EventDetailsController eventDetailsController = Get.find();
  TextEditingController bookingId = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List buttonlist1 = [];

  var res1;

  @override
  void initState() {
    // TODO: implement initState
    currentdate =
        '${DateFormat('yyyy').format(selectedDateAndTime)}-${DateFormat('MM').format(selectedDateAndTime)}-${DateFormat('dd').format(selectedDateAndTime)}';
    super.initState();
  }

  var selectedRadioTile;
  String rejectmsg = "";
  List cancelList = [
    {"id": 1, "title": "Financing fell through".tr},
    {"id": 2, "title": "Inspection issues".tr},
    {"id": 3, "title": "Change in financial situation".tr},
    {"id": 4, "title": "Title issues".tr},
    {"id": 5, "title": "Seller changes their mind".tr},
    {"id": 6, "title": "Competing offer".tr},
    {"id": 7, "title": "Personal reasons".tr},
    {"id": 8, "title": "Others".tr},
  ];
  TextEditingController note = TextEditingController();

  Barcode? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // TicketInfo? ticketInfo;
  QRViewController? controller;
  int currentIndex = 0;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  Scanorcode? data1;

  Future scanqrcode() async {
    Map body = {
      'seat_no_cancel': cancelseatnumber.join(','),
      'seat_no_conform': conforeseatnumber.join(','),
      'book_date':
          "${DateFormat('yyyy').format(selectedDateAndTime)}-${DateFormat('MM').format(selectedDateAndTime)}-${DateFormat('dd').format(selectedDateAndTime)}",
      'cancle_reason': rejectmsg == "Others".tr ? note.text : rejectmsg
    };

    print("+++ $body");

    try {
      var response = await http.post(
          Uri.parse('${config().baseUrl}/scan_qr.php'),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });

      print("respons body +++++ ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          data1 = scanorcodeFromJson(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data1!.responseMsg),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        });
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  List cancelseatnumber = [];
  List conforeseatnumber = [];
  String bookid = "";

  String currentdate = "";
  String bookingdate = "";

  int indexvalue = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: Get.size.height,
                width: Get.size.width,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: (QRViewController controller) {
                    setState(() {
                      this.controller = controller;
                    });
                    controller.scannedDataStream.listen((scanData) {
                      if (scanData.rawBytes!.isNotEmpty) {
                        controller.pauseCamera();
                        setState(() {
                          result = scanData;
                          res1 = jsonDecode(result!.code.toString());
                          print("::::::::::::::::::::" + res1.toString());

                          List seatid = [];
                          List pessengerName = [];

                          List blocc = [];

                          seatid = res1['seat_no'].toString().split(',');
                          pessengerName =
                              res1['pessenger_name'].toString().split(',');

                          bookid = res1['book_id'];
                          bookingdate = res1['book_date'];
                          setState(() {});

                          print(":::::::::: bookingdatebookingdate ::::::::::" +
                              bookingdate);
                          print(":::::::::: currentdatecurrentdate ::::::::::" +
                              currentdate);

                          if (bookingdate.compareTo(currentdate) == 0) {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      topLeft: Radius.circular(15))),
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Container(
                                      // height: 200,
                                      // width: 200,
                                      decoration: BoxDecoration(
                                        color: notifier.containercoloreproper,
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15)),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ListView.separated(
                                                separatorBuilder:
                                                    (context, index) {
                                                  print(blocc);
                                                  return const SizedBox(
                                                    width: 0,
                                                    height: 10,
                                                  );
                                                },
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: seatid.length,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${pessengerName[index]}',
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              '${seatid[index]}',
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (buttonlist1
                                                                          .contains(
                                                                              "Cancel-$index") ==
                                                                      true) {
                                                                    buttonlist1
                                                                        .remove(
                                                                            "Cancel-$index");
                                                                    cancelseatnumber
                                                                        .remove(
                                                                            seatid[index]);
                                                                  } else {
                                                                    buttonlist1
                                                                        .remove(
                                                                            "Checking-$index");
                                                                    buttonlist1.add(
                                                                        "Cancel-$index");
                                                                    conforeseatnumber
                                                                        .remove(
                                                                            seatid[index]);
                                                                    cancelseatnumber
                                                                        .add(seatid[
                                                                            index]);
                                                                  }
                                                                });
                                                                print(
                                                                    "++++-------+++${buttonlist1}");
                                                              },
                                                              child: Container(
                                                                height: 30,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                    color: buttonlist1.contains(
                                                                            "Cancel-$index")
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    border: Border.all(
                                                                        color: buttonlist1.contains("Cancel-$index")
                                                                            ? Colors.transparent
                                                                            : Colors.grey.withOpacity(0.4))),
                                                                child: Center(
                                                                    child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      color: buttonlist1.contains(
                                                                              "Cancel-$index")
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      fontSize:
                                                                          10),
                                                                )),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (buttonlist1
                                                                          .contains(
                                                                              "Checking-$index") ==
                                                                      true) {
                                                                    buttonlist1
                                                                        .remove(
                                                                            "Checking-$index");
                                                                    conforeseatnumber
                                                                        .remove(
                                                                            seatid[index]);
                                                                  } else {
                                                                    buttonlist1
                                                                        .remove(
                                                                            "Cancel-$index");
                                                                    buttonlist1.add(
                                                                        "Checking-$index");
                                                                    cancelseatnumber
                                                                        .remove(
                                                                            seatid[index]);
                                                                    conforeseatnumber
                                                                        .add(seatid[
                                                                            index]);
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 30,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                    color: buttonlist1.contains(
                                                                            "Checking-$index")
                                                                        ? notifier
                                                                            .theamcolorelight
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    border: Border.all(
                                                                        color: buttonlist1.contains("Checking-$index")
                                                                            ? Colors.transparent
                                                                            : Colors.grey.withOpacity(0.4))),
                                                                child: Center(
                                                                    child: Text(
                                                                  'Checking',
                                                                  style: TextStyle(
                                                                      color: buttonlist1.contains(
                                                                              "Checking-$index")
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      fontSize:
                                                                          10),
                                                                )),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: buttonlist1.length ==
                                                      seatid.length
                                                  ? CommonButton(
                                                      containcolore: notifier
                                                          .theamcolorelight,
                                                      onPressed1: () {},
                                                      txt1: 'PROCEED',
                                                      context: context)
                                                  : CommonButton(
                                                      containcolore:
                                                          Color(0xffD6C1F9),
                                                      onPressed1: () {},
                                                      txt1: 'PROCEED',
                                                      context: context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            Get.back();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please Select Today`s Date'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        });
                        controller.resumeCamera();
                      } else {
                        controller.resumeCamera();
                      }
                    });
                  },
                  overlay: QrScannerOverlayShape(
                    borderColor: notifier.appbarcolore,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 5,
                    cutOutSize: 200,
                  ),
                  onPermissionSet: (ctrl, p) =>
                      _onPermissionSet(context, ctrl, p),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  height: 45,
                  width: 45,
                  alignment: Alignment.center,
                  child: BackButton(
                    onPressed: () {
                      Get.back();
                    },
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 10,
                right: 10,
                child: Container(
                  height: 50,
                  width: Get.size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = 0;
                              controller?.resumeCamera();
                            });
                          },
                          child: Container(
                            height: 45,
                            margin: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                            alignment: Alignment.center,
                            child: Text(
                              "Scan Code",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: currentIndex == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  textfield1(
      {String? type,
      labelText,
      prefixtext,
      suffix,
      Color? labelcolor,
      prefixcolor,
      floatingLabelColor,
      focusedBorderColor,
      TextDecoration? decoration,
      bool? readOnly,
      double? Width,
      int? max,
      TextEditingController? controller,
      TextInputType? textInputType,
      Function(String)? onChanged,
      String? Function(String?)? validator,
      List<TextInputFormatter>? inputFormatters,
      Height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type ?? "",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: Get.height * 0.01),
        Container(
          height: Height,
          width: Width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: Colors.black,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: max,
            readOnly: readOnly ?? false,
            inputFormatters: inputFormatters,
            style: TextStyle(color: Colors.black, fontSize: 18),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Gilroy Medium",
                  fontSize: 16),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      // ApiWrapper.showToastMessage("No Permissiom");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('no Permission')),
      // );
    }
  }

  var selectedDateAndTime = DateTime.now();

  Future<void> selectDateAndTime(context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateAndTime,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff7D2AFF),
              onPrimary: Colors.white,
              onSurface: Color(0xff7D2AFF),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                // primary: Colors.black,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    print(pickedDate);
    if (pickedDate != null && pickedDate != selectedDateAndTime) {
      setState(() {
        selectedDateAndTime = pickedDate;
      });
    }
  }
}

ticketbutton(
    {required void Function() ontapped,
    String? title,
    Color? bgColor,
    titleColor,
    Gradient? gradient1}) {
  return InkWell(
    onTap: ontapped,
    child: Container(
      height: Get.height * 0.04,
      width: Get.width * 0.40,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient1,
        borderRadius: (BorderRadius.circular(10)),
      ),
      child: Center(
        child: Text(title!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: titleColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontFamily: 'Gilroy Medium')),
      ),
    ),
  );
}
