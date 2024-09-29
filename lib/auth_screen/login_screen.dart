// ignore_for_file: camel_case_types, file_names, avoid_print, depend_on_referenced_packages, empty_catches, unnecessary_brace_in_string_interps, non_constant_identifier_names, unnecessary_import

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/screens/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_code/common_button.dart';
import '../config/config.dart';
import '../config/dark_light.dart';
import 'package:http/http.dart' as http;



class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  List lottie12 = [
    "assets/lottie/1st.json",
    "assets/lottie/2nd.json",
    "assets/lottie/3rd.json",
  ];

  List title = [
    "Your Driver Companion App",
    "Drivers, Enhancing Journeys!",
    "Scan, Validate, Go!",
  ];

  List description = [
    'Stay on track with intuitive route guidance and real-time updates..',
    'Streamline operations, optimize routes, and foster smoother travels for passengers..',
    'Validate tickets swiftly, ensuring smooth boarding for passengers..',
  ];

  @override
  void dispose() {
    super.dispose();
    isloding = false;
  }

  bool isloding = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController rcodeController = TextEditingController();

  String phonenumber = '';



  bool isPassword = false;

  //Forgot screen code


  String ccodeforgot ="";
  String phonenumberforgot = '';
  TextEditingController mobileControllerforgot = TextEditingController();





// 1 time Login and remove code

  resetNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', false);
  }

  Future login(String email,password) async {
    Map body = {
      'email' : email,
      'password' : password
    };
    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/driver_login.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        var data = jsonDecode(response.body.toString());
        print("++++++++++++-+++++++++++++-+++++++++${data}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // initPlatformState();

        prefs.setString("loginData", jsonEncode(data["UserLogin"]));
        // prefs.setString("currency", jsonEncode(data["currency"]));

        return data;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  bool passwordvalidate = false;
  bool? isLogin;

  @override
  void initState() {

    super.initState();
  }

  ColorNotifier notifier = ColorNotifier();

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.4)),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    Text('Welcome aboard ProZigzagBus Driver!'.tr,style:  TextStyle(fontFamily: 'SofiaProBold',fontSize: 16,color: notifier.textColor)),
                    const SizedBox(height: 6,),
                    Text('Login to ProZigzagBus Driver'.tr,style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.textColor)),
                    const SizedBox(height: 20,),

                    CommonTextfiled2(controller: emailcontroller,txt: 'Enter Your Email'.tr,context: context),

                    const SizedBox(height: 10,),
                    // CommonTextfiled2(controller: passwordcontroller,txt: 'Enter Your Password'.tr,context: context),
                    TextField(
                      controller: passwordcontroller,
                      obscureText: _obscureText,
                      style: TextStyle(color: notifier.textColor),
                      decoration: InputDecoration(
                        suffixIconColor: notifier.theamcolorelight,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText =! _obscureText;
                            });
                          },
                          child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,size: 20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.red)),
                        enabledBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                        hintText: "Enter Your Password",hintStyle:  const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 14),
                        focusedBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: notifier.theamcolorelight)),
                      ),
                    ),
                    const SizedBox(height: 10,),

                    CommonButton(txt1: 'Login'.tr,containcolore: notifier.theamcolorelight,context: context,onPressed1: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => Bottom_Navigation(),));
                      if(emailcontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty){
                        login(emailcontroller.text,passwordcontroller.text,).then((value) {
                          print("++++++$value");
                          if(value["ResponseCode"] == "200"){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                            );

                            resetNew();



                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Bottom_Navigation(),), (route) => false);
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                            );
                          }
                        });
                      }

                    }),
                    const SizedBox(height: 20,),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Stack(
          children: [
            SizedBox(
              height: Get.height,
              child: Column(
                children: <Widget>[

                  // const SizedBox(height: 30,),
                  const Spacer(flex: 1),
                  Column(
                    children: [
                      const Image(image: AssetImage('assets/logo.png'),height: 70,width: 70),
                      Text('ProZigzagDriver'.tr,style: TextStyle(color: notifier.theamcolorelight,fontSize: 20,fontFamily: 'SofiaProBold'),),
                    ],
                  ),

                  const Spacer(flex: 1),
                  CarouselSlider(
                      items: [
                        for(int a =0; a< lottie12.length;a++) Column(
                          children: [
                            Lottie.asset(lottie12[a],height: 200),
                            const SizedBox(height: 30,),

                            Text(title[a].toString().tr,style:  TextStyle(color: notifier.textColor,fontFamily: 'SofiaProBold',fontSize: 18),),
                            const SizedBox(height: 5,),
                            Container(
                              height : 2,
                              width: 70,
                              color: notifier.theamcolorelight,
                            ),
                            const SizedBox(height: 15,),
                            Expanded(
                              child: SizedBox(
                                // height: 50,
                                width: 200,
                                child: Text('${description[a]}',style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 13),textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                        ),
                      ],
                      options: CarouselOptions(
                        height: 345,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 2),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.3,
                        scrollDirection: Axis.horizontal,
                      )
                  ),
                  const Spacer(flex: 10),
                ],
              ),
            ),
            isloding?  Center(child: Padding(padding: const EdgeInsets.only(top: 400), child: CircularProgressIndicator(color: notifier.theamcolorelight),)):const SizedBox(),
          ],
        ),
      ),
    );
  }





}
