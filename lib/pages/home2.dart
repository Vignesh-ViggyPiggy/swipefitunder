/*
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/provider/CardProvider.dart';
import 'package:swipefit/resources/auth_methods.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> _usernamesMap = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).resetUsers();
    });
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final uid = await AuthMethods().getCurrentUserId();
      final receivedRequests = await AuthMethods().getReceivedRequests(uid);
      final usernamesMap =
          await AuthMethods().getUsernamesFromUids(receivedRequests);
      setState(() {
        _usernamesMap = usernamesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(String senderUid) async {
    try {
      final currentUid = await AuthMethods().getCurrentUserId();
      await AuthMethods().acceptFriendRequest(currentUid, senderUid);
      setState(() {
        _usernamesMap.removeWhere((key, value) => value == senderUid);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _declineFriendRequest(String senderUid) async {
    try {
      final currentUid = await AuthMethods().getCurrentUserId();
      await AuthMethods().declineFriendRequest(currentUid, senderUid);
      setState(() {
        _usernamesMap.removeWhere((key, value) => value == senderUid);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight =
        screenHeight / 1.618; // Card height is 1 / 1.618 of screen height
    final cardWidth = cardHeight * .75;
    final cardSize = Size(cardWidth, cardHeight);

    print('Building HomePage');

    final cardState = ref.watch(cardProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('SWIPE FIT'),
        actions: [
          // Add a notification button to the app bar
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Open the notification drawer when the button is pressed
              Scaffold.of(context).openEndDrawer();
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: cardState.when(
        data: (urlImages) {
          if (urlImages.isEmpty) {
            return Center(
              child: ElevatedButton(
                child: const Text('Reset Cards'),
                onPressed: () => ref.read(cardProvider.notifier).resetUsers(),
              ),
            );
          } else {
            return Column(
              children: [
                Center(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: SizedBox(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          ...urlImages.map(
                            (urlImage) => TinderCard(
                              urlImage: urlImage,
                              isFront: urlImages.last == urlImage,
                              cardSize: cardSize,
                            ),
                          ),
                          // Profile Info Positioned
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 20,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: cardWidth / 1.5,
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                ),
                                const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.heart_broken_outlined),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.reply),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      endDrawer: // Add a notification drawer
          Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text('Notifications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _usernamesMap.isEmpty
                          ? Center(child: Text('No friend requests'))
                          : ListView.builder(
                              itemCount: _usernamesMap.length,
                              itemBuilder: (context, index) {
                                final username =
                                    _usernamesMap.keys.elementAt(index);
                                final uid = _usernamesMap[username]!;
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Friend request from $username',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _acceptFriendRequest(uid),
                                              child: Text('Accept'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.green,
                                                backgroundColor:
                                                    Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _declineFriendRequest(uid),
                                              child: Text('Discard'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                backgroundColor:
                                                    Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class TinderCard extends ConsumerStatefulWidget {
  final String urlImage;
  final bool isFront;
  final Size cardSize;

  const TinderCard({
    required this.urlImage,
    required this.isFront,
    required this.cardSize,
  });

  @override
  _TinderCardState createState() => _TinderCardState();
}

class _TinderCardState extends ConsumerState<TinderCard> {
  bool _isDragging = false;
  Timer? _draggingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(cardProvider.notifier).setScreenSize(widget.cardSize);
      }
    });
  }

  @override
  void dispose() {
    _draggingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('Building TinderCard: ${widget.urlImage}');
    return SizedBox(
      width: widget.cardSize.width,
      height: widget.cardSize.height,
      child: widget.isFront ? buildFrontCard() : buildCard(),
    );
  }

  Widget buildFrontCard() {
    final provider = ref.read(cardProvider.notifier);
    final notifier = ValueNotifier(provider);
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          //print('Widget rebuilt');
          final provider = ref.read(cardProvider.notifier);
          final position = provider.position;
          final angle = provider.angle;
          final milliseconds = provider.milliseconds;

          final center = constraints.smallest.center(Offset.zero);
          final rotatedAngle = angle * pi / 180;
          final rotatedMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(rotatedAngle)
            ..translate(-center.dx, -center.dy);

          return AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: milliseconds),
            transform: rotatedMatrix..translate(position.dx, position.dy),
            child: buildCard(),
          );
        },
      ),
      onPanStart: (details) {
        ref.read(cardProvider.notifier).startPosition(details);
        _isDragging = true;
        _draggingTimer = Timer.periodic(Duration(milliseconds: 5), (timer) {
          if (_isDragging) {
            setState(() {
              // Update the position here if needed
            });
          } else {
            timer.cancel();
          }
        });
      },
      onPanUpdate: (details) {
        ref.read(cardProvider.notifier).updatePosition(details);
        setState(() {
          // Ensure the position is updated immediately
        });
      },
      onPanEnd: (details) {
        ref.read(cardProvider.notifier).endPosition();
        _isDragging = false;
      },
    );
  }

  Widget buildCard() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.urlImage),
              fit: BoxFit.cover,
              alignment: const Alignment(-0.3, 0),
            ),
          ),
        ),
      );
}

*/

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/provider/CardProvider.dart';
import 'package:swipefit/resources/auth_methods.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> _usernamesMap = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).resetUsers();
    });
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final uid = await AuthMethods().getCurrentUserId();
      final receivedRequests = await AuthMethods().getReceivedRequests(uid);
      final usernamesMap =
          await AuthMethods().getUsernamesFromUids(receivedRequests);
      setState(() {
        _usernamesMap = usernamesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(String senderUid) async {
    try {
      final currentUid = await AuthMethods().getCurrentUserId();
      await AuthMethods().acceptFriendRequest(currentUid, senderUid);
      setState(() {
        _usernamesMap.removeWhere((key, value) => value == senderUid);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _declineFriendRequest(String senderUid) async {
    try {
      final currentUid = await AuthMethods().getCurrentUserId();
      await AuthMethods().declineFriendRequest(currentUid, senderUid);
      setState(() {
        _usernamesMap.removeWhere((key, value) => value == senderUid);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight =
        screenHeight / 1.618; // Card height is 1 / 1.618 of screen height
    final cardWidth = cardHeight * .75;
    final cardSize = Size(cardWidth, cardHeight);

    print('Building HomePage');

    final cardState = ref.watch(cardProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('SWIPE FIT'),
        actions: [
          // Add a notification button to the app bar
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Open the notification drawer when the button is pressed
              Scaffold.of(context).openEndDrawer();
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: cardState.when(
        data: (urlImages) {
          if (urlImages.isEmpty) {
            return Center(
              child: ElevatedButton(
                child: const Text('Reset Cards'),
                onPressed: () => ref.read(cardProvider.notifier).resetUsers(),
              ),
            );
          } else {
            return Column(
              children: [
                Center(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: SizedBox(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          ...urlImages.map(
                            (urlImage) => TinderCard(
                              urlImage: urlImage,
                              isFront: urlImages.last == urlImage,
                              cardSize: cardSize,
                            ),
                          ),
                          // Profile Info Positioned
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 20,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: cardWidth / 1.5,
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                ),
                                const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.heart_broken_outlined),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.reply),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Colors.white,
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      endDrawer: // Add a notification drawer
          Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text('Notifications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _usernamesMap.isEmpty
                          ? Center(child: Text('No friend requests'))
                          : ListView.builder(
                              itemCount: _usernamesMap.length,
                              itemBuilder: (context, index) {
                                final username =
                                    _usernamesMap.keys.elementAt(index);
                                final uid = _usernamesMap[username]!;
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Friend request from $username',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _acceptFriendRequest(uid),
                                              child: Text('Accept'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.green,
                                                backgroundColor:
                                                    Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _declineFriendRequest(uid),
                                              child: Text('Discard'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                backgroundColor:
                                                    Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class TinderCard extends ConsumerStatefulWidget {
  final String urlImage;
  final bool isFront;
  final Size cardSize;

  const TinderCard({
    required this.urlImage,
    required this.isFront,
    required this.cardSize,
  });

  @override
  _TinderCardState createState() => _TinderCardState();
}

class _TinderCardState extends ConsumerState<TinderCard> {
  bool _isDragging = false;
  Timer? _draggingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(cardProvider.notifier).setScreenSize(widget.cardSize);
      }
    });
  }

  @override
  void dispose() {
    _draggingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('Building TinderCard: ${widget.urlImage}');
    return SizedBox(
      width: widget.cardSize.width,
      height: widget.cardSize.height,
      child: widget.isFront ? buildFrontCard() : buildCard(),
    );
  }

  Widget buildFrontCard() {
    final provider = ref.read(cardProvider.notifier);
    final notifier = ValueNotifier(provider);
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          //print('Widget rebuilt');
          final provider = ref.read(cardProvider.notifier);
          final position = provider.position;
          final angle = provider.angle;
          final milliseconds = provider.isDragging ? 0 : 400;

          final center = constraints.smallest.center(Offset.zero);
          final rotatedAngle = angle * pi / 180;
          final rotatedMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(rotatedAngle)
            ..translate(-center.dx, -center.dy);

          return AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: milliseconds),
            transform: rotatedMatrix..translate(position.dx, position.dy),
            child: buildCard(),
          );
        },
      ),
      onPanStart: (details) {
        ref.read(cardProvider.notifier).startPosition(details);
        _isDragging = true;
        _draggingTimer = Timer.periodic(Duration(milliseconds: 5), (timer) {
          if (_isDragging) {
            setState(() {
              // Update the position here if needed
            });
          } else {
            timer.cancel();
          }
        });
      },
      onPanUpdate: (details) {
        ref.read(cardProvider.notifier).updatePosition(details);
        setState(() {
          // Ensure the position is updated immediately
        });
      },
      onPanEnd: (details) {
        ref.read(cardProvider.notifier).endPosition();
        _isDragging = false;
      },
    );
  }

  Widget buildCard() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.urlImage),
              fit: BoxFit.cover,
              alignment: const Alignment(-0.3, 0),
            ),
          ),
        ),
      );
}
