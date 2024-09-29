// ignore_for_file: camel_case_types, file_names, avoid_print, depend_on_referenced_packages, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously, unused_local_variable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/screens/page_list_description_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common_Code/common_button.dart';
import '../api_model/page_list_api_model.dart';
import '../auth_screen/login_screen.dart';
import '../common_code/language_controller.dart';
import '../config/config.dart';
import '../config/dark_light.dart';
import '../config/homecontroller.dart';
import 'faq_screen.dart';
import 'package:http/http.dart' as http;


class MyAccount_Screen extends StatefulWidget {
  const MyAccount_Screen({super.key});

  @override
  State<MyAccount_Screen> createState() => _MyAccount_ScreenState();
}

class _MyAccount_ScreenState extends State<MyAccount_Screen> {

  List text21 = [
    'Personal info'.tr,
    'Faq'.tr,
    'Dark Mode'.tr,
  ];

  List image = [
    'assets/b1.png',
    'assets/b6.png',
    'assets/b7.png',
  ];

  List text = [
    'Privacy Policy',
    'Terms & Conditions',
    'Contact Us',
    'Cancellation Policy',
  ];

  bool isloading = true;

  @override
  void initState() {
    super.initState();
    getlocledata();
    pagelistapi();

  }

  var userData;
  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      fun();
      pagelistapi();
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+bhjgbkjsnlskn-+-+${userData["id"]}');
    });
  }

  bool light = true;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();


  int value = 0;
  bool isChecked = false;

  language1 language11 = Get.put(language1());

  List languageimage = [
    'assets/L-English.png',
    'assets/L-Spanish.png',
    'assets/L-Arabic.png',
    'assets/L-Hindi-Gujarati.png',
    'assets/L-Hindi-Gujarati.png',
    'assets/L-Afrikaans.png',
    'assets/L-Bengali.png',
    'assets/L-Indonesion.png',
  ];

  List languagetext = [
    'English',
    'Spanish',
    'Arabic',
    'Hindi',
    'Gujarati',
    'Afrikaans',
    'Bengali',
    'Indonesian',
  ];

  ColorNotifier notifier = ColorNotifier();

  List languagetext1 = [
    'en_English',
    'en_spanse',
    'ur_arabic',
    'en_Hindi',
    'en_Gujarati',
    'en_African',
    'en_Bangali',
    'en_Indonesiya',
  ];

  fun(){

    for(int a= 0 ;a<languagetext1.length;a++){
      print(languagetext1[a]);
      print(Get.locale);
      if(languagetext1[a].toString().compareTo(Get.locale.toString()) == 0){
        setState(() {
          value = a;
        });

      }else{

      }
    }

  }

  //  GET API CALLING
  PageList? from12;

  Future pagelistapi() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl2}/api/pagelist.php'),);
    if (response1.statusCode == 200) {
      print(response1.body);
      var jsonData = json.decode(response1.body);
      setState(() {
        from12 = pageListFromJson(response1.body);
        isloading = false;
      });
    }
  }

  bool rtl = false;



  Future Prifile_edite_Api() async {

    Map body = {
      'name' : namecontroller.text,
      'password': passwordcontroller.text,
      'mobile': mobilecontroller.text,
      'driver_id': userData["id"],
    };

    print("+++ $body");
    try{
      var response2 = await http.post(Uri.parse('${config().baseUrl}/profile_edit.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response2.body);
      if(response2.statusCode == 200){
        return jsonDecode(response2.body);
      }else{
        print('failed');
      }

    }catch(e){
      print(e.toString());
    }
  }



  Future Delete_Api_Class() async {

    Map body = {
      'driver_id' : userData["id"],
    };

    print("+++ $body");

    try{
      var response2 = await http.post(Uri.parse('${config().baseUrl}/acc_delete.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response2.body);
      if(response2.statusCode == 200){
        return jsonDecode(response2.body);
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
    return GetBuilder<HomeController>(
        builder: (homeController) {
          return Scaffold(
            // backgroundColor: const Color(0xffF5F5F5),
            backgroundColor:  notifier.background,
            appBar: AppBar(
              backgroundColor:notifier.appbarcolore,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Center(child: Text('My Profile'.tr,style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold))),
            ),
            body: isloading ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight)) :  SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        namecontroller.text = userData["driver_name"];
                        emailcontroller.text = userData["email"];
                        passwordcontroller.text = userData["password"];
                        mobilecontroller.text = userData["mobile"];
                        Get.bottomSheet(isScrollControlled: true,
                            Container(
                              // height: 420,
                              decoration:  BoxDecoration(
                                color: notifier.backgroundgray,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                              ),
                              child:  Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(height: 10,),
                                    Text('Profile Edit',style: TextStyle(color: notifier.textColor,fontSize: 20,fontFamily: 'SofiaProBold'),),
                                    const SizedBox(height: 10,),
                                    CommonTextfiled200(txt: 'harsh',controller: namecontroller,context: context),
                                    const SizedBox(height: 10,),
                                    // CommonTextfiled200(txt: 'harsh@gmail.com',controller: emailcontroller,context: context),
                                    TextField(
                                      readOnly: true,
                                      controller: emailcontroller,
                                      style: TextStyle(color: notifier.textColor),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.red)),
                                        enabledBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                                        hintText: userData["email"],hintStyle:  const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 14),
                                        focusedBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: notifier.theamcolorelight)),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    CommonTextfiled10(txt: '123',controller: passwordcontroller,context: context),
                                    const SizedBox(height: 10,),


                                    IntlPhoneField(

                                      readOnly: true,
                                      decoration:  InputDecoration(
                                        counterText: "",
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        contentPadding: const EdgeInsets.only(top: 8),
                                        hintText: "${userData["mobile"]}",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,fontWeight: FontWeight.bold
                                        ),
                                        border:  OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.grey,),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Color(0xff7D2AFF)),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      flagsButtonPadding: EdgeInsets.zero,
                                      showCountryFlag: false,
                                      showDropdownIcon: false,
                                      initialCountryCode: 'IN',
                                      dropdownTextStyle:  TextStyle(color: notifier.textColor,fontSize: 15),
                                      // style: const TextStyle(color: Colors.black,fontSize: 16),
                                      onChanged: (number) {
                                        setState(() {
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10,),
                                    CommonButton(txt1: 'Confirm'.tr,containcolore: notifier.theamcolorelight,context: context,onPressed1: () {
                                      Get.back();
                                      if(namecontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty){
                                        Prifile_edite_Api().then((value) async {

                                          SharedPreferences pre = await SharedPreferences.getInstance();
                                          pre.setString("loginData", jsonEncode(value["UserLogin"]));
                                          getlocledata();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                          );
                                        });
                                      }else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Enter Input'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                        );
                                      }
                                    }),
                                    const SizedBox(height: 20,),
                                  ],
                                ),
                              ),
                            ));
                      },
                      child: ListTile(
                        leading: Transform.translate(offset: const Offset(-25, 0),child: CircleAvatar(backgroundColor: Colors.grey.withOpacity(0.2),radius: 35,child: Text(userData['driver_name'][0],style:  TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: notifier.theamcolorelight)),)),
                        title: Transform.translate(offset: const Offset(-35, 0),child: Text(userData['driver_name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: notifier.textColor))),
                        subtitle: Transform.translate(offset: const Offset(-35, 0),child: Text(userData['mobile'],style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15))),
                        trailing:  Image(image: const AssetImage('assets/pen-line.png'),height: 25,width: 25,color: notifier.theamcolorelight),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text('General'.tr,style: TextStyle(color: notifier.textColor)),
                    ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 5,);
                        },
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: text21.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              switch(index){
                                case  0:
                                  namecontroller.text = userData["driver_name"];
                                  emailcontroller.text = userData["email"];
                                  passwordcontroller.text = userData["password"];
                                  mobilecontroller.text = userData["mobile"];
                                  Get.bottomSheet(
                                      isScrollControlled: true,
                                      Container(
                                        decoration:  BoxDecoration(
                                          color: notifier.backgroundgray,
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                        ),
                                        child:  Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const SizedBox(height: 10,),
                                              Text('Profile Edit',style: TextStyle(color: notifier.textColor,fontSize: 20,fontFamily: 'SofiaProBold'),),
                                              const SizedBox(height: 10,),
                                              CommonTextfiled200(txt: 'harsh',controller: namecontroller,context: context),
                                              const SizedBox(height: 10,),
                                              // CommonTextfiled200(txt: 'harsh@gmail.com',controller: emailcontroller,context: context),
                                              TextField(
                                                readOnly: true,
                                                controller: emailcontroller,
                                                style: TextStyle(color: notifier.textColor),
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.red)),
                                                  enabledBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                                                  hintText: userData["email"],hintStyle:  const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 14),
                                                  focusedBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: notifier.theamcolorelight)),
                                                ),
                                              ),
                                              const SizedBox(height: 10,),
                                              CommonTextfiled10(txt: '123',controller: passwordcontroller,context: context),
                                              const SizedBox(height: 10,),

                                              IntlPhoneField(
                                                readOnly: true,
                                                decoration:  InputDecoration(
                                                  counterText: "",
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  contentPadding: const EdgeInsets.only(top: 8),
                                                  hintText: userData["mobile"],
                                                  hintStyle: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,fontWeight: FontWeight.bold
                                                  ),
                                                  border:  OutlineInputBorder(
                                                      borderSide: const BorderSide(color: Colors.grey,),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(color: Color(0xff7D2AFF)),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                ),
                                                flagsButtonPadding: EdgeInsets.zero,
                                                showCountryFlag: false,
                                                showDropdownIcon: false,
                                                initialCountryCode: 'IN',
                                                dropdownTextStyle:  TextStyle(color: notifier.textColor,fontSize: 15),
                                                // style: const TextStyle(color: Colors.black,fontSize: 16),
                                                onChanged: (number) {
                                                  setState(() {

                                                  });
                                                },
                                              ),
                                              const SizedBox(height: 10,),
                                              CommonButton(txt1: 'Confirm'.tr,containcolore:  notifier.theamcolorelight,context: context,onPressed1:  () {
                                                Get.back();
                                                if(namecontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty){
                                                  Prifile_edite_Api().then((value) async {

                                                    SharedPreferences pre = await SharedPreferences.getInstance();
                                                    pre.setString("loginData", jsonEncode(value["UserLogin"]));
                                                    getlocledata();

                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                                    );
                                                  });
                                                }else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Enter Input'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                                  );
                                                }
                                              }),
                                              const SizedBox(height: 20,),
                                            ],
                                          ),
                                        ),
                                      ));
                                case 1:
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  const Faq_Screeen(),));
                                case 2:
                                  return;
                              }
                            },
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.comfortable,
                              leading: Transform.translate(offset:  const Offset(-15, 0),child: Image(image: AssetImage(image[index]),height: 25,width: 25,color: notifier.textColor,)),
                              title: Transform.translate(offset:  const Offset(-20, 0),child: Text(text21[index].toString().tr,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: notifier.textColor))),
                              trailing: index == 2 ?  SizedBox(
                                height: 20,
                                width: 30,
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: CupertinoSwitch(
                                    // This bool value toggles the switch.
                                    value: notifier.isDark,
                                    activeColor: notifier.theamcolorelight,
                                    onChanged: (bool value) {
                                      notifier.isAvailable(value);
                                    },
                                  ),
                                ),
                              ) :  Icon(Icons.chevron_right,color: notifier.textColor),
                            ),
                          );
                        }),
                    const SizedBox(height: 20,),
                    Text('About'.tr,style: TextStyle(color: notifier.textColor)),
                    const SizedBox(height: 20,),
                    ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 5);
                        },
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: from12!.pagelist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Page_List_description(title: from12!.pagelist[index].title,description: from12!.pagelist[index].description),));
                            },
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.comfortable,
                              leading: Transform.translate(offset: const Offset(-15, 0),child:  Image(image: const AssetImage('assets/a3.png'),height: 25,width: 25,color: notifier.textColor,)),
                              title: Transform.translate(offset: const Offset(-20, 0),child: Text('${from12?.pagelist[index].title}',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: notifier.textColor))),
                              trailing: Icon(Icons.chevron_right,color: notifier.textColor),
                            ),
                          );
                        }),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              decoration:  BoxDecoration(
                                  color: notifier.containercoloreproper,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(height: 25,),
                                    Text('Delete Account'.tr,style:  TextStyle(color:notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 20)),
                                    const SizedBox(height: 12.5),
                                    const Divider(color: Colors.grey,),
                                    const SizedBox(height: 12.5,),
                                    Text('Are you sure you want to delete account?'.tr,style: TextStyle(color: notifier.textColor,fontSize: 16,fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 25,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(130, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                                          onPressed: () => Navigator.pop(context),
                                          child:  Text('Cancel'.tr,style: const TextStyle(color: Colors.black)),
                                        ),
                                        const SizedBox(width: 10,),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            fixedSize: MaterialStateProperty.all(const Size(130, 40)),
                                            elevation: MaterialStateProperty.all(0),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(notifier.theamcolorelight),
                                          ),
                                          onPressed: () => {
                                            Delete_Api_Class().then((value) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                              );
                                            }),
                                            homeController.setselectpage(0),
                                            Get.offAll(const Login_Screen())
                                          },
                                          child:  Text('Yes,Remove'.tr,style: const TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.comfortable,
                        leading: Transform.translate(offset: const Offset(-15, 0),child: Image(image: const AssetImage('assets/a6.png'),height: 25,width: 25,color: notifier.textColor,)),
                        title: Transform.translate(offset: const Offset(-20, 0),child: Text('Delete Account'.tr,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: notifier.textColor))),
                        trailing: Icon(Icons.chevron_right,color: notifier.textColor),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              decoration:  BoxDecoration(
                                  color: notifier.containercoloreproper,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const SizedBox(height: 25,),
                                  Text('Logout'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 20)),
                                  const SizedBox(height: 25,),
                                  Text('Are you sure you want to log out?'.tr,style: TextStyle(color: notifier.textColor,fontSize: 16,fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 25,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'.tr,style: const TextStyle(color: Colors.black)),
                                      ),
                                      const SizedBox(width: 10,),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          fixedSize: MaterialStateProperty.all(const Size(120, 40)),
                                          elevation: MaterialStateProperty.all(0),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          backgroundColor: MaterialStateProperty.all(notifier.theamcolorelight),
                                        ),
                                        onPressed: () => {
                                          resetNew(),
                                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const Login_Screen(),)),
                                          homeController.setselectpage(0),
                                          Get.offAll(const Login_Screen())
                                        },
                                        child: Text('Yes,Logout'.tr,style: const TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.comfortable,
                        leading: Transform.translate(offset: const Offset(-12, 0),child: const Image(image: AssetImage('assets/Logout.png'),height: 25,width: 25,)),
                        title: Transform.translate(offset: const Offset(-20, 0),child: Text('Logout'.tr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.red))),
                      ),
                    ),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget CheckboxListTile(int index) {
    return SizedBox(
      height: 24,
      width: 24,
      child: ElevatedButton(
        onPressed: () {
          value = index;
          setState(() {
            value = index;

            switch (index) {
              case 0:
                Get.updateLocale(
                    const Locale('en', 'English'));

                Get.back();
                break;
              case 1:
                Get.updateLocale(
                    const Locale('en', 'spanse'));

                Get.back();
                break;
              case 2:
                Get.updateLocale(
                    const Locale('en', 'arabic'));

                Get.back();
                break;
              case 3:
                Get.updateLocale(
                    const Locale('en', 'Hindi'));

                Get.back();
                break;
              case 4:
                Get.updateLocale(
                    const Locale('en', 'Gujarati'));

                Get.back();
                break;
              case 5:
                Get.updateLocale(
                    const Locale('en', 'African'));

                Get.back();
                break;
              case 6:
                Get.updateLocale(
                    const Locale('en', 'Bangali'));

                Get.back();
                break;
              case 7:
                Get.updateLocale(
                    const Locale('en', 'Indonesiya'));

                Get.back();

            }

          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xffEEEEEE),
          side: BorderSide(
            color: (value == index)
                ? Colors.transparent
                : Colors.transparent,
            width: (value == index) ? 2 : 2,
          ),
          padding: const EdgeInsets.all(0),
        ),
        child: Center(
            child: Icon(
              Icons.check,
              color: value == index ? Colors.black : Colors.transparent,
              size: 18,
            )),
      ),
    );
  }

}

resetNew() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLogin', true);
}

