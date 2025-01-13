import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Page"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[700],
                    child: Image.asset('assets/icon.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Pawan PR",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "@pawan420",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("0", "posts"),
                      _buildStat("0", "swipe ratio"),
                      _buildStat("0", "friends"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 1,
            ),

            // TabBar for Posts and Cart
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    color: Colors
                        .grey[900], // Highlight color for the selected tab
                    borderRadius: BorderRadius.circular(50.0),
                    shape: BoxShape.rectangle),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Posts"),
                  Tab(text: "Cart"),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // TabBarView for switching content
            Expanded(
              child: TabBarView(
                children: [
                  // Posts Tab Content
                  Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        "Posts Content",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Cart Tab Content
                  Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        "Cart Content",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building stats
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
