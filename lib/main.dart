// ignore_for_file: use_super_parameters, avoid_print

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:prozigzag_driver/splase_screen.dart';
import 'config/dark_light.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ColorNotifier(),),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en', 'English'),
        theme: ThemeData(
          useMaterial3: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          fontFamily: 'SofiaProLight',
        ),
        home: const Splase_Screen(),
      ),);
  }
}

