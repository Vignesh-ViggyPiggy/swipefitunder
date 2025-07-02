/*
import 'dart:async';
import 'dart:math';
import 'package:swipefit/provider/ExploreCardProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:swipefit/provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StorePage extends ConsumerStatefulWidget {
  final Function addCartItem;

  const StorePage({super.key, required this.addCartItem});

  @override
  ConsumerState<StorePage> createState() => _StorePageState();
}

class _StorePageState extends ConsumerState<StorePage> {
  int _selectedcloth = -1;
  final List<Map<String, dynamic>> cartImages =
      []; // new list to store cart images

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final images = ref.watch(imagesProvider);
    //final image_link = ref.watch(imageLinkProvider);
    final item_list = ref.watch(items_from_databaseProvider);
    final size = MediaQuery.of(context).size;

    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight =
        screenHeight / 1.618; // Card height is 1 / 1.618 of screen height
    final cardWidth = cardHeight * .75;
    final cardSize = Size(cardWidth, cardHeight);

    print('Building Store');

    final cardState = ref.watch(exploreCardProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("SWIPE FIT"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Search"),
              Tab(text: "Explore"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Search Tab
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.82,
                child: item_list.when(
                  data: (data) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedcloth = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 10, 10, 10),
                              border: Border.all(
                                  color: _selectedcloth == index
                                      ? Colors.grey
                                      : Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data[index]['ItemImage'],
                                      width: size.width,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                if (_selectedcloth == index)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _launchUrl(
                                                  data[index]['ItemLink']);
                                            },
                                            child: const Text(
                                              "BUY",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color.fromRGBO(
                                                      224, 224, 224, 1)),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                cartImages.add(data[index]);
                                              });
                                              widget.addCartItem(data[
                                                  index]); // Add item to cart
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(100,
                                                  40), // set a minimum size for the button
                                            ),
                                            child: const Text(
                                              "ADD TO CART",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      224,
                                                      224,
                                                      224,
                                                      1)), // reduce font size to fit
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (e, stackTrace) => Text('Error: $e'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            // Explore Tab

            cardState.when(
              data: (urlImages) {
                if (urlImages.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      child: const Text('Reset Cards'),
                      onPressed: () =>
                          ref.read(exploreCardProvider.notifier).resetUsers(),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottom Action Buttons
                    ],
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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
        ref.read(exploreCardProvider.notifier).setScreenSize(widget.cardSize);
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
    final provider = ref.read(exploreCardProvider.notifier);
    final notifier = ValueNotifier(provider);
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          //print('Widget rebuilt');
          final provider = ref.read(exploreCardProvider.notifier);
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
        ref.read(exploreCardProvider.notifier).startPosition(details);
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
        ref.read(exploreCardProvider.notifier).updatePosition(details);
        setState(() {
          // Ensure the position is updated immediately
        });
      },
      onPanEnd: (details) {
        ref.read(exploreCardProvider.notifier).endPosition();
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
import 'package:swipefit/provider/ExploreCardProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:swipefit/provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StorePage extends ConsumerStatefulWidget {
  final Function addCartItem;

  const StorePage({super.key, required this.addCartItem});

  @override
  ConsumerState<StorePage> createState() => _StorePageState();
}

class _StorePageState extends ConsumerState<StorePage> {
  int _selectedcloth = -1;
  final List<Map<String, dynamic>> cartImages =
      []; // new list to store cart images

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final images = ref.watch(imagesProvider);
    //final image_link = ref.watch(imageLinkProvider);
    final item_list = ref.watch(items_from_databaseProvider);
    final size = MediaQuery.of(context).size;

    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight =
        screenHeight / 1.618; // Card height is 1 / 1.618 of screen height
    final cardWidth = cardHeight * .75;
    final cardSize = Size(cardWidth, cardHeight);

    print('Building Store');

    final cardState = ref.watch(exploreCardProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("SWIPE FIT"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Search"),
              Tab(text: "Explore"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Search Tab
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.82,
                child: item_list.when(
                  data: (data) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedcloth = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 10, 10, 10),
                              border: Border.all(
                                  color: _selectedcloth == index
                                      ? Colors.grey
                                      : Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data[index]['ItemImage'],
                                      width: size.width,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                if (_selectedcloth == index)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _launchUrl(
                                                  data[index]['ItemLink']);
                                            },
                                            child: const Text(
                                              "BUY",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color.fromRGBO(
                                                      224, 224, 224, 1)),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                cartImages.add(data[index]);
                                              });
                                              widget.addCartItem(data[
                                                  index]); // Add item to cart
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(100,
                                                  40), // set a minimum size for the button
                                            ),
                                            child: const Text(
                                              "ADD TO CART",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      224,
                                                      224,
                                                      224,
                                                      1)), // reduce font size to fit
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (e, stackTrace) => Text('Error: $e'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            // Explore Tab

            cardState.when(
              data: (urlImages) {
                if (urlImages.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      child: const Text('Reset Cards'),
                      onPressed: () =>
                          ref.read(exploreCardProvider.notifier).resetUsers(),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottom Action Buttons
                    ],
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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
        ref.read(exploreCardProvider.notifier).setScreenSize(widget.cardSize);
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
    final provider = ref.read(exploreCardProvider.notifier);
    final notifier = ValueNotifier(provider);
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          //print('Widget rebuilt');
          final provider = ref.read(exploreCardProvider.notifier);
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
        ref.read(exploreCardProvider.notifier).startPosition(details);
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
        ref.read(exploreCardProvider.notifier).updatePosition(details);
        setState(() {
          // Ensure the position is updated immediately
        });
      },
      onPanEnd: (details) {
        ref.read(exploreCardProvider.notifier).endPosition();
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
