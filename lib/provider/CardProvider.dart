import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

final cardProvider = AsyncNotifierProvider<CardNotifier, List<String>>(
  CardNotifier.new,
);

enum CardStatus { like, dislike, superLike }

class CardNotifier extends AsyncNotifier<List<String>> {
  List<String> _urlImages = [];
  bool _isDragging = false;
  Offset _position = Offset.zero;
  double _angle = 0;
  Size _screenSize = Size.zero;

  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  @override
  FutureOr<List<String>> build() async {
    // Initial list of images
    _urlImages = [
      'https://picsum.photos/id/1/720/1280.jpg',
      'https://picsum.photos/id/2/720/1280.jpg',
      'https://picsum.photos/id/31/720/1280.jpg',
      'https://picsum.photos/id/32/720/1280.jpg',
      'https://picsum.photos/id/33/720/1280.jpg',
    ];
    return _urlImages;
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;
  }

  void endPosition() {
    _isDragging = false;
    final status = getStatus(force: true);

    switch (status) {
      case CardStatus.like:
        like();
        break;
      case CardStatus.dislike:
        dislike();
        break;
      case CardStatus.superLike:
        superLike();
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0;
  }

  CardStatus? getStatus({bool force = false}) {
    final x = _position.dx;
    final y = _position.dy;
    final forceSuperLike = x.abs() < 20;

    if (force) {
      const delta = 100;

      if (x >= delta) {
        return CardStatus.like;
      } else if (x <= -delta) {
        return CardStatus.dislike;
      } else if (y <= -delta / 2 && forceSuperLike) {
        return CardStatus.superLike;
      }
    } else {
      const delta = 20;

      if (y <= -delta * 2 && forceSuperLike) {
        return CardStatus.superLike;
      } else if (x >= delta) {
        return CardStatus.like;
      } else if (x <= -delta) {
        return CardStatus.dislike;
      }
    }

    return null;
  }

  void like() {
    _angle = 20;
    _position += Offset(_screenSize.width * 1.5, 0);
    nextCard();
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);
    nextCard();
  }

  void superLike() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    nextCard();
  }

  Future<void> nextCard() async {
    if (_urlImages.isEmpty) return;

    await Future.delayed(Duration(milliseconds: 200));
    _urlImages.removeLast();
    resetPosition();
    state =
        AsyncValue.data(_urlImages); // Update state with the remaining images
  }

  void resetUsers() {
    state = AsyncValue.data([
      'https://picsum.photos/id/1/720/1280.jpg',
      'https://picsum.photos/id/2/720/1280.jpg',
      'https://picsum.photos/id/31/720/1280.jpg',
      'https://picsum.photos/id/32/720/1280.jpg',
      'https://picsum.photos/id/33/720/1280.jpg',
    ]);
    _urlImages = state.value!;
    resetPosition();
  }
}





// // import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:flutter/material.dart';


// enum CardStatus { like, dislike, superLike }

// class CardProvider extends ChangeNotifier {
//   // final firebase_storage.FirebaseStorage storage =
//   //     firebase_storage.FirebaseStorage.instance;

//   //final Storage serverstorage = Storage();

//   List<Map<String, String?>> _urlImages = [];
//   List<Map<String, String?>> get urlImages => _urlImages;

//   bool _isDragging = false;
//   bool get isDragging => _isDragging;

//   Offset _position = Offset.zero;
//   Offset get position => _position;

//   double _angle = 0;
//   double get angle => _angle;

//   Size _screenSize = Size.zero;
//   Size get screenSize => _screenSize;

//   CardProvider() {
//     print('Initializing cards');
//     loadImages();
//   }

//   void setScreenSize(Size screenSize) => _screenSize = screenSize;

//   void startPosition(DragStartDetails details) {
//     _isDragging = true;
//     notifyListeners();
//   }

//   void updatePosition(DragUpdateDetails details) {
//     _position += details.delta;
//     final x = _position.dx;
//     _angle = 45 * x / _screenSize.width;
//     notifyListeners();
//   }

//   Future<void> swipe_update(dynamic prid, String status) async {
//     // try {
//     //   var namedata =
//     //       FirebaseFirestore.instance.collection("globalpics").doc(prid);
//     //   namedata.update({status: FieldValue.increment(1)});
//     //   // print('$prid,  $status');
//     // } on Exception catch (e) {
//     //   print(e);
//     // }
//   }

//   void endPosition(pid) {
//     _isDragging = false;
//     notifyListeners();

//     final status = getStatus(force: true);

//     // if (status != null) {
//     //   Fluttertoast.cancel();
//     //   Fluttertoast.showToast(
//     //     msg: status.toString().split('.').last.toUpperCase(),
//     //     fontSize: 30,
//     //   );
//     }

//     switch (status) {
//       case CardStatus.like:
//         like();
//         swipe_update(pid, 'like');
//         break;
//       case CardStatus.dislike:
//         dislike();
//         swipe_update(pid, 'dislike');
//         break;
//       case CardStatus.superLike:
//         superLike();
//         swipe_update(pid, 'superLike');
//         break;
//       default:
//         resetPosition();
//     }
//   }

//   void resetPosition() {
//     _isDragging = false;
//     _position = Offset.zero;
//     _angle = 0;
//     notifyListeners();
//   }

//   CardStatus? getStatus({bool force = false}) {
//     final x = _position.dx;
//     final y = _position.dy;
//     final forceSuperLike = x.abs() < 20;

//     if (force) {
//       const delta = 100;

//       if (x >= delta) {
//         return CardStatus.like;
//       } else if (x <= -delta) {
//         return CardStatus.dislike;
//       } else if (y <= -delta / 2 && forceSuperLike) {
//         return CardStatus.superLike;
//       }
//     } else {
//       const delta = 20;

//       if (y <= -delta * 2 && forceSuperLike) {
//         return CardStatus.superLike;
//       } else if (x >= delta) {
//         return CardStatus.like;
//       } else if (x <= -delta) {
//         return CardStatus.dislike;
//       }
//     }

//     return null;
//   }

//   void like() {
//     _angle = 20;
//     _position += Offset(_screenSize.width * 1.5, 0);
//     nextCard();
//     notifyListeners();
//   }

//   void dislike() {
//     _angle = -20;
//     _position -= Offset(_screenSize.width * 1.5, 0);
//     nextCard();
//     notifyListeners();
//   }

//   void superLike() {
//     _angle = 0;
//     _position -= Offset(0, _screenSize.height);
//     nextCard();
//     notifyListeners();
//   }

//   Future nextCard() async {
//     if (_urlImages.isEmpty) return;

//     await Future.delayed(const Duration(milliseconds: 200));
//     _urlImages.removeLast();
//     resetPosition();
//   }

//   Future<void> loadImages() async {
//     print('start');
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         QuerySnapshot<Map<String, dynamic>> receivedPicsSnapshot =
//             // await FirebaseFirestore.instance
//             //     .collection("users")
//             //     .doc(user.uid)
//             //     .collection('recivedpics')
//             //     .get();
//             // wLqzXTudraZoM1HvD8ZRo1pWqXO2
//             await FirebaseFirestore.instance
//                 .collection("users")
//                 .doc(user.uid.toString())
//                 .collection('recivedpics')
//                 .get();

//         List<Map<String, String?>> picUrls = [];

//         for (var doc in receivedPicsSnapshot.docs) {
//           final picId = doc.data()['picdata'] as String;
//           DocumentSnapshot<Map<String, dynamic>> picDataSnapshot =
//               await FirebaseFirestore.instance
//                   .collection("globalpics")
//                   .doc(picId)
//                   .get();

//           // final picUrl = picDataSnapshot.data()?['pic_url'] as String?;
//           final picUrl = {
//             'pic_url': picDataSnapshot.data()?['pic_url'] as String?,
//             'pid': picId
//           };
//           picUrls.add(picUrl);
//         }
//         print(picUrls.reversed.toList());
//         _urlImages = picUrls.reversed.toList();
//         notifyListeners();
//       } catch (e) {
//         print("Error fetching data: $e");
//       }
//     }
//   }

//   void resetUsers() {
//     loadImages();
//   }
// }


// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// enum CardStatus { like, dislike, superLike }

// final cardProvider = AsyncNotifierProvider<CardNotifier, List<Map<String, String?>>>(CardNotifier.new);

// class CardNotifier extends AsyncNotifier<List<Map<String, String?>>> {
//   final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

//   bool _isDragging = false;
//   Offset _position = Offset.zero;
//   double _angle = 0;
//   Size _screenSize = Size.zero;

//   bool get isDragging => _isDragging;
//   Offset get position => _position;
//   double get angle => _angle;
//   Size get screenSize => _screenSize;

//   void setScreenSize(Size screenSize) => _screenSize = screenSize;

//   Future<void> loadImages() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         QuerySnapshot<Map<String, dynamic>> receivedPicsSnapshot = await FirebaseFirestore.instance
//             .collection("users")
//             .doc(user.uid)
//             .collection('recivedpics')
//             .get();

//         List<Map<String, String?>> picUrls = [];
//         for (var doc in receivedPicsSnapshot.docs) {
//           final picId = doc.data()['picdata'] as String;
//           DocumentSnapshot<Map<String, dynamic>> picDataSnapshot =
//               await FirebaseFirestore.instance.collection("globalpics").doc(picId).get();

//           final picUrl = {
//             'pic_url': picDataSnapshot.data()?['pic_url'] as String?,
//             'pid': picId
//           };
//           picUrls.add(picUrl);
//         }

//         state = AsyncData(picUrls.reversed.toList());
//       } catch (e) {
//         state = AsyncError(e);
//       }
//     }
//   }

//   Future<void> swipeUpdate(String picId, String status) async {
//     try {
//       await FirebaseFirestore.instance.collection("globalpics").doc(picId).update({
//         status: FieldValue.increment(1),
//       });
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: "Failed to update swipe: $e",
//         fontSize: 16,
//       );
//     }
//   }

//   void startPosition(DragStartDetails details) {
//     _isDragging = true;
//   }

//   void updatePosition(DragUpdateDetails details) {
//     _position += details.delta;
//     final x = _position.dx;
//     _angle = 45 * x / _screenSize.width;
//   }

//   void endPosition(String picId) {
//     _isDragging = false;

//     final status = getStatus(force: true);

//     if (status != null) {
//       Fluttertoast.cancel();
//       Fluttertoast.showToast(
//         msg: status.toString().split('.').last.toUpperCase(),
//         fontSize: 30,
//       );
//     }

//     switch (status) {
//       case CardStatus.like:
//         swipeUpdate(picId, 'like');
//         break;
//       case CardStatus.dislike:
//         swipeUpdate(picId, 'dislike');
//         break;
//       case CardStatus.superLike:
//         swipeUpdate(picId, 'superLike');
//         break;
//       default:
//         resetPosition();
//     }
//   }

//   void resetPosition() {
//     _isDragging = false;
//     _position = Offset.zero;
//     _angle = 0;
//   }

//   CardStatus? getStatus({bool force = false}) {
//     final x = _position.dx;
//     final y = _position.dy;
//     final forceSuperLike = x.abs() < 20;

//     if (force) {
//       const delta = 100;

//       if (x >= delta) {
//         return CardStatus.like;
//       } else if (x <= -delta) {
//         return CardStatus.dislike;
//       } else if (y <= -delta / 2 && forceSuperLike) {
//         return CardStatus.superLike;
//       }
//     } else {
//       const delta = 20;

//       if (y <= -delta * 2 && forceSuperLike) {
//         return CardStatus.superLike;
//       } else if (x >= delta) {
//         return CardStatus.like;
//       } else if (x <= -delta) {
//         return CardStatus.dislike;
//       }
//     }

//     return null;
//   }
// }
