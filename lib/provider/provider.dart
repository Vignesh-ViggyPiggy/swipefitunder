import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swipefit/resources/auth_methods.dart';

enum CardStatus { like, dislike, superLike }

final cardProvider =
    AsyncNotifierProvider<CardNotifier, List<Map<String, String?>>>(
        CardNotifier.new);

class CardNotifier extends AsyncNotifier<List<Map<String, String?>>> {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  bool _isDragging = false;
  Offset _position = Offset.zero;
  double _angle = 0;
  Size _screenSize = Size.zero;

  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;
  Size get screenSize => _screenSize;

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  Future<void> loadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> receivedPicsSnapshot =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection('recivedpics')
                .get();

        List<Map<String, String?>> picUrls = [];
        for (var doc in receivedPicsSnapshot.docs) {
          final picId = doc.data()['picdata'] as String;
          DocumentSnapshot<Map<String, dynamic>> picDataSnapshot =
              await FirebaseFirestore.instance
                  .collection("globalpics")
                  .doc(picId)
                  .get();

          final picUrl = {
            'pic_url': picDataSnapshot.data()?['pic_url'] as String?,
            'pid': picId
          };
          picUrls.add(picUrl);
        }

        state = AsyncData(picUrls.reversed.toList());
      } catch (e, stackTrace) {
        state = AsyncError(e, stackTrace);
      }
    }
  }

  Future<void> swipeUpdate(String picId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection("globalpics")
          .doc(picId)
          .update({
        status: FieldValue.increment(1),
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update swipe: $e",
        fontSize: 16,
      );
    }
  }

  void startPosition(DragStartDetails details) {
    _isDragging = true;
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;
  }

  void endPosition(String picId) {
    _isDragging = false;

    final status = getStatus(force: true);

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: status.toString().split('.').last.toUpperCase(),
        fontSize: 30,
      );
    }

    switch (status) {
      case CardStatus.like:
        swipeUpdate(picId, 'like');
        break;
      case CardStatus.dislike:
        swipeUpdate(picId, 'dislike');
        break;
      case CardStatus.superLike:
        swipeUpdate(picId, 'superLike');
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

  @override
  FutureOr<List<Map<String, String?>>> build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}

final uploadProvider = AsyncNotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);

class UploadState {
  final bool isUploading;
  final bool isUploaded;
  const UploadState({this.isUploading = false, this.isUploaded = false});

  UploadState copyWith({bool? isUploading, bool? isUploaded}) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

class UploadNotifier extends AsyncNotifier<UploadState> {
  @override
  FutureOr<UploadState> build() => const UploadState();

  Future<void> uploadImage(String name, String path, String uid,
      Future<void> Function(String, String, String) uploadServer) async {
    state = const UploadState(isUploading: true) as AsyncValue<UploadState>;
    try {
      // Simulate storage upload delay
      await Future.delayed(const Duration(seconds: 5));
      await uploadServer(name, "1", uid);
      state = const UploadState(isUploaded: true) as AsyncValue<UploadState>;
    } catch (e) {
      state = const UploadState(isUploading: false) as AsyncValue<UploadState>;
      rethrow;
    }
  }
}

final items_from_databaseProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AuthMethods().storeData();
});

final useridProvider = FutureProvider<String>((ref) async {
  return await AuthMethods().getCurrentUserId();
});

// final posts_from_databaseProvider =
//     FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   final userId = ref.watch(useridProvider);
//   return await AuthMethods().postData(userId as String);
// });
// final usernamesProvider =
//     FutureProvider.family<List<String>, String>((ref, query) async {
//   return await AuthMethods().getUsernamesContaining(query);
// });
final usernamesProvider =
    FutureProvider.family<Map<String, String>, String>((ref, query) async {
  return await AuthMethods().getUsernamesContaining(query);
});

// final receivedRequestsProvider = FutureProvider<List<String>>((ref) async {
//   final uid = await ref.watch(useridProvider.future);
//   return await AuthMethods().getReceivedRequests(uid);
// });

// final usernamesFromReceivedRequestsProvider =
//     FutureProvider<Map<String, String>>((ref) async {
//   final receivedRequests = await ref.watch(receivedRequestsProvider.future);
//   return await AuthMethods().getUsernamesFromUids(receivedRequests);
// });
