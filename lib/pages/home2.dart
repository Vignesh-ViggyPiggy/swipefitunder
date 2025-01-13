import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/provider/CardProvider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).resetUsers();
    });
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
      appBar: AppBar(
        title: const Text('SWIPE FIT'),
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
  Widget build(BuildContext context) {
    print('Building TinderCard: ${widget.urlImage}');
    return SizedBox(
      width: widget.cardSize.width,
      height: widget.cardSize.height,
      child: widget.isFront ? buildFrontCard() : buildCard(),
    );
  }

  Widget buildFrontCard() => GestureDetector(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = ref.watch(cardProvider.notifier);
            final position = provider.position;
            final milliseconds = provider.isDragging ? 0 : 400;

            final center = constraints.smallest.center(Offset.zero);
            final angle = provider.angle * pi / 180;
            final rotatedMatrix = Matrix4.identity()
              ..translate(center.dx, center.dy)
              ..rotateZ(angle)
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
        },
        onPanUpdate: (details) {
          ref.read(cardProvider.notifier).updatePosition(details);
        },
        onPanEnd: (details) {
          ref.read(cardProvider.notifier).endPosition();
        },
      );

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
