import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "SWIPE FIT",
          textAlign: TextAlign.left,
        ),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Card
          Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // Profile Image
                  Image.asset(
                    'assets/icon.jpg', // Replace with your image URL
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                  // User Info Overlay
                  const Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 20,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "username",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.heart_broken_outlined),
                  color: Colors.white,
                  iconSize: 28,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.reply),
                  color: Colors.white,
                  iconSize: 28,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.favorite_outline),
                  color: Colors.white,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
