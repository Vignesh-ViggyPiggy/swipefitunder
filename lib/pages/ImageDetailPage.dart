// import 'package:flutter/material.dart';

// class ImageDetailPage extends StatefulWidget {
//   final List<Map<String, dynamic>> posts;
//   final int initialIndex;

//   const ImageDetailPage(
//       {Key? key, required this.posts, required this.initialIndex})
//       : super(key: key);

//   @override
//   _ImageDetailPageState createState() => _ImageDetailPageState();
// }

// class _ImageDetailPageState extends State<ImageDetailPage>
//     with SingleTickerProviderStateMixin {
//   late int _currentIndex;
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _shadowAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
//         .animate(_controller);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);
//     _shadowAnimation =
//         Tween<double>(begin: 4.0, end: 20.0).animate(_controller);
//   }

//   void _onVerticalDragUpdate(DragUpdateDetails details) {
//     if (details.primaryDelta! < -10) {
//       // Swiped up
//       if (_currentIndex < widget.posts.length - 1) {
//         setState(() {
//           _slideAnimation =
//               Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
//                   .animate(_controller);
//           _controller.forward().then((_) {
//             setState(() {
//               _currentIndex++;
//               _controller.reset();
//             });
//           });
//         });
//       }
//     } else if (details.primaryDelta! > 10) {
//       // Swiped down
//       if (_currentIndex > 0) {
//         setState(() {
//           _slideAnimation =
//               Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
//                   .animate(_controller);
//           _controller.forward().then((_) {
//             setState(() {
//               _currentIndex--;
//               _controller.reset();
//             });
//           });
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final post = widget.posts[_currentIndex];
//     final imageUrl = post['postImage'];
//     final likes = post['likes'] as List<dynamic>;
//     final dislikes = post['dislikes'] as List<dynamic>;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Image Detail"),
//       ),
//       body: GestureDetector(
//         onVerticalDragUpdate: _onVerticalDragUpdate,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Container(
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.5),
//                     blurRadius: _shadowAnimation.value,
//                     spreadRadius: _shadowAnimation.value,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(20.0),
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Text(
//                         'Likes: ${likes.length}',
//                         style:
//                             const TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       Text(
//                         'Dislikes: ${dislikes.length}',
//                         style:
//                             const TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ImageDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final int initialIndex;

  const ImageDetailPage(
      {Key? key, required this.posts, required this.initialIndex})
      : super(key: key);

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150), // Faster animation
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);
    _shadowAnimation =
        Tween<double>(begin: 4.0, end: 20.0).animate(_controller);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! < -10) {
      // Swiped up
      if (_currentIndex < widget.posts.length - 1) {
        setState(() {
          _slideAnimation =
              Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
                  .animate(_controller);
          _controller.forward().then((_) {
            setState(() {
              _currentIndex++;
              _controller.reset();
            });
          });
        });
      }
    } else if (details.primaryDelta! > 10) {
      // Swiped down
      if (_currentIndex > 0) {
        setState(() {
          _slideAnimation =
              Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
                  .animate(_controller);
          _controller.forward().then((_) {
            setState(() {
              _currentIndex--;
              _controller.reset();
            });
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[_currentIndex];
    final imageUrl = post['postImage'];
    final likes = post['likes'] as List<dynamic>;
    final dislikes = post['dislikes'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Detail"),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: _shadowAnimation.value,
                    spreadRadius: _shadowAnimation.value,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${likes.length}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            'Likes',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${dislikes.length}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            'Dislikes',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
