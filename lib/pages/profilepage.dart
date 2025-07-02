/*
import 'package:flutter/material.dart';
import 'package:swipefit/pages/ImageDetailPage.dart';
import 'package:swipefit/resources/auth_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.cartImages});
  final List<Map<String, dynamic>> cartImages;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

@override
class _ProfilePageState extends State<ProfilePage> {
  // Create a Set to store unique items in the cart
  Set<Map<String, dynamic>> _uniqueCartItems = {};
  List<Map<String, dynamic>> _posts = [];

// Initialize the Set in the initState method
  @override
  void initState() {
    super.initState();
    _uniqueCartItems = {};
    for (var item in widget.cartImages) {
      _uniqueCartItems.add(item);
    }
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final currentUid = await AuthMethods().getCurrentUserId();
    final posts = await AuthMethods().getPostDetailsByUserUid(currentUid);
    setState(() {
      _posts = posts;
    });
  }

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
                  FutureBuilder(
                    future: AuthMethods().getCurrentUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return Text(
                          "Loading...",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  FutureBuilder(
                    future: AuthMethods().getCurrentUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "@${snapshot.data}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        return Text(
                          "@loading...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("0", "posts"),
                      _buildStat("0", "credits"),
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
                dividerColor: Colors.transparent,
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
                    color: Colors.grey[900],
                    child: _posts.isEmpty
                        ? const Center(
                            child: Text(
                              "No posts available",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            ),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageDetailPage(
                                        posts: _posts,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  post['postImage'],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),

                  // Cart Tab Content

                  Container(
                      color: Colors.grey[900],
                      child: _uniqueCartItems.isEmpty
                          ? const Center(
                              child: Text(
                                "No items in cart",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _uniqueCartItems.length,
                              itemBuilder: (context, index) {
                                var item = _uniqueCartItems.elementAt(index);
                                return Row(
                                  children: [
                                    Image.network(
                                      item['ItemImage'],
                                      width: 75,
                                      height: 75,
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        item['ItemName'],
                                        maxLines: null,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Spacer(),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final url = item[
                                                'ItemLink']; // Assuming the URL is the same as the image URL
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          child: Text("BUY",
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              )),
                                        ),
                                        SizedBox(height: 5),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              widget.cartImages.removeWhere(
                                                  (element) => element == item);
                                              _uniqueCartItems.remove(item);
                                            });
                                          },
                                          child: Text("REMOVE",
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            )),
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


*/

import 'package:flutter/material.dart';
import 'package:swipefit/pages/ImageDetailPage.dart';
import 'package:swipefit/resources/auth_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.cartImages});
  final List<Map<String, dynamic>> cartImages;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

@override
class _ProfilePageState extends State<ProfilePage> {
  // Create a Set to store unique items in the cart
  Set<Map<String, dynamic>> _uniqueCartItems = {};
  List<Map<String, dynamic>> _posts = [];
  int _numPosts = 0;
  int _numFriends = 0;
// Initialize the Set in the initState method
  @override
  void initState() {
    super.initState();
    _uniqueCartItems = {};
    for (var item in widget.cartImages) {
      _uniqueCartItems.add(item);
    }
    _fetchPosts();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final currentUid = await AuthMethods().getCurrentUserId();
    final friends = await AuthMethods().fetchFriends(currentUid);
    setState(() {
      _numFriends = friends.length;
    });
  }

  Future<void> _fetchPosts() async {
    final currentUid = await AuthMethods().getCurrentUserId();
    final posts = await AuthMethods().getPostDetailsByUserUid(currentUid);
    setState(() {
      _posts = posts;
      _numPosts = posts.length;
    });
  }

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
                  FutureBuilder(
                    future: AuthMethods().getCurrentUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return Text(
                          "Loading...",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  FutureBuilder(
                    future: AuthMethods().getCurrentUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "@${snapshot.data}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        return Text(
                          "@loading...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("$_numPosts", "posts"),
                      _buildStat("0", "credits"),
                      _buildStat("$_numFriends", "friends"),
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
                dividerColor: Colors.transparent,
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
                    color: Colors.grey[900],
                    child: _posts.isEmpty
                        ? const Center(
                            child: Text(
                              "No posts available",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            ),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageDetailPage(
                                        posts: _posts,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  post['postImage'],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),

                  // Cart Tab Content

                  Container(
                      color: Colors.grey[900],
                      child: _uniqueCartItems.isEmpty
                          ? const Center(
                              child: Text(
                                "No items in cart",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _uniqueCartItems.length,
                              itemBuilder: (context, index) {
                                var item = _uniqueCartItems.elementAt(index);
                                return Row(
                                  children: [
                                    Image.network(
                                      item['ItemImage'],
                                      width: 75,
                                      height: 75,
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        item['ItemName'],
                                        maxLines: null,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Spacer(),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final url = item[
                                                'ItemLink']; // Assuming the URL is the same as the image URL
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          child: Text("BUY",
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              )),
                                        ),
                                        SizedBox(height: 5),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              widget.cartImages.removeWhere(
                                                  (element) => element == item);
                                              _uniqueCartItems.remove(item);
                                            });
                                          },
                                          child: Text("REMOVE",
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            )),
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
