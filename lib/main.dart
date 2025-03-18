import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/filter_provider.dart';
import 'providers/location_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

late Size mq;

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.checkPermission();
  await _initializeFirebase();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      ChangeNotifierProvider(create: (_) => FilterProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CityBuddy',
      theme: lightMode,
      darkTheme: darkMode,
      home: const SplashScreen(),
    );
  }
}
