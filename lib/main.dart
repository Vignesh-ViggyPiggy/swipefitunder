import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/firebase_options.dart';

import 'package:swipefit/pages/mainpage.dart';
import 'package:swipefit/pages/profilepage.dart';
import 'package:swipefit/pages/settingspage.dart';

import 'pages/login.dart';
import 'pages/signup.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize cameras
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Error initializing Firebase or cameras: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
        '/mainpage': (context) => MainPage(),
        '/settings': (context) => Settingspage(),
      },
    );
  }
}
