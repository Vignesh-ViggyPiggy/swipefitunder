// import 'package:camera/camera.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:swipefit/firebase_options.dart';

// import 'package:swipefit/pages/mainpage.dart';
// import 'package:swipefit/pages/profilepage.dart';
// import 'package:swipefit/pages/settingspage.dart';

// import 'pages/login.dart';
// import 'pages/signup.dart';

// List<CameraDescription> cameras = [];
// FirebaseApp? secondaryApp;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Initialize Firebase
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     secondaryApp = await Firebase.initializeApp(
//       name: "storageApp",
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyAk0clZvgRODmVfVu9LBp3DIZdJyiNHx0Q",
//         //authDomain: "YOUR_STORAGE_PROJECT.firebaseapp.com",
//         projectId: "ratefit-8df99",
//         storageBucket: "ratefit-8df99.appspot.com",
//         messagingSenderId: "518279335908",
//         appId: "1:518279335908:android:bd33be11d51ebc538bc1f1",
//       ),
//     );

//     // Initialize cameras
//     cameras = await availableCameras();
//   } catch (e) {
//     debugPrint("Error initializing Firebase or cameras: $e");
//   }

//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark(),
//       //initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginPage(),
//         '/signup': (context) => const SignUpPage(),
//         '/profile': (context) => const ProfilePage(
//               cartImages: [],
//             ),
//         '/mainpage': (context) => MainPage(),
//         '/settings': (context) => Settingspage(),
//       },
//       home: StreamBuilder(
//           stream: FirebaseAuth.instance.idTokenChanges(),
//           builder: (context, snapshot) =>
//               snapshot.connectionState == ConnectionState.waiting
//                   ? const CircularProgressIndicator()
//                   : snapshot.hasData
//                       ? const MainPage()
//                       : LoginPage()),
//     );
//   }
// }

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
FirebaseApp? secondaryApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    secondaryApp = await Firebase.initializeApp(
      name: "storageApp",
      options: const FirebaseOptions(
        apiKey: "AIzaSyAk0clZvgRODmVfVu9LBp3DIZdJyiNHx0Q",
        //authDomain: "YOUR_STORAGE_PROJECT.firebaseapp.com",
        projectId: "ratefit-8df99",
        storageBucket: "ratefit-8df99.appspot.com",
        messagingSenderId: "518279335908",
        appId: "1:518279335908:android:bd33be11d51ebc538bc1f1",
      ),
    );

    // Initialize cameras
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Error initializing Firebase or cameras: $e");
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      //initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(
              cartImages: [],
            ),
        '/mainpage': (context) => MainPage(),
        '/settings': (context) => Settingspage(),
      },
      home: StreamBuilder(
          stream: FirebaseAuth.instance.idTokenChanges(),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : snapshot.hasData
                      ? const MainPage()
                      : LoginPage()),
    );
  }
}
