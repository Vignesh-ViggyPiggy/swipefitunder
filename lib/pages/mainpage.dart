import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipefit/main.dart';
import 'package:swipefit/pages/Friends.dart';
//import 'package:swipefit/pages/Home.dart';
import 'package:swipefit/pages/profilepage.dart';
// import 'package:swipefit/pages/homepage.dart';
import 'package:swipefit/pages/home2.dart';
import 'package:swipefit/pages/store.dart';
import 'package:swipefit/camerapage/camera.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> cartImages = [];
  void addCartItem(Map<String, dynamic> item) {
    setState(() {
      cartImages.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const HomePage(),
      FriendsPage(),
      //Home(),
      CameraApp(camera: cameras),
      StorePage(addCartItem: addCartItem),
      ProfilePage(cartImages: cartImages),
    ];

    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Friend",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Store",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
