//CardProvider.dart
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';

import 'package:swipefit/resources/auth_methods.dart';

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
  ////////
  int _milliseconds = 400;
  int get milliseconds => _milliseconds;
  ////////
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  @override
  //FutureOr<List<String>> build() async {
  FutureOr<List<String>> build() {
    _urlImages = [
      // 'https://picsum.photos/id/1/720/1280.jpg',
      // 'https://picsum.photos/id/2/720/1280.jpg',
      // 'https://picsum.photos/id/31/720/1280.jpg',
      // 'https://picsum.photos/id/32/720/1280.jpg',
      // 'https://picsum.photos/id/33/720/1280.jpg',
    ];
    return _urlImages;
    // resetUsers();
    // return _urlImages;
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    _position = Offset.zero; /////////////
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    final y = _position.dy;

    // Calculate the angle based on the horizontal movement
    _angle = 45 * x / _screenSize.width;

    // Ensure the milliseconds value is always positive
    _milliseconds = (400 - (_position.distance * 2).toInt()).clamp(1, 500);
  }

  void endPosition() {
    _isDragging = false;
    final status = getStatus(force: true);

    switch (status) {
      case CardStatus.like:
        like();
        ////////////////////////
        _position = Offset(_screenSize.width, 0);
        _angle = 0;
        //////////////////////////
        break;
      case CardStatus.dislike:
        dislike();
        ////////////////////////
        _position = Offset(_screenSize.width * -1, 0);
        _angle = 0;
        //////////////////////////
        break;
      case CardStatus.superLike:
        superLike();
        ////////////////////////
        _position = Offset(0, _screenSize.height * -1);
        _angle = 0;
        //////////////////////////
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _position = Offset.zero;
    _angle = 0;
    _isDragging = false;
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

    _showToast('Liked!');
    AuthMethods().likePost(_urlImages.last);
    nextCard();
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);

    _showToast('Disliked!');
    AuthMethods().dislikePost(_urlImages.last);
    nextCard();
  }

  void superLike() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    nextCard();
    _showToast('Super Liked!');
  }

  Future<void> nextCard() async {
    if (_urlImages.isEmpty) return;

    // await Future.delayed(Duration(milliseconds: 300));
    _urlImages.removeLast();
    await Future.delayed(Duration(milliseconds: 300));
    resetPosition();
    state =
        AsyncValue.data(_urlImages); // Update state with the remaining images
  }

  Future<void> resetUsers() async {
    // state = AsyncValue.data([
    //   'https://picsum.photos/id/1/720/1280.jpg',
    //   'https://picsum.photos/id/2/720/1280.jpg',
    //   'https://picsum.photos/id/31/720/1280.jpg',
    //   'https://picsum.photos/id/32/720/1280.jpg',
    //   'https://picsum.photos/id/33/720/1280.jpg',
    // ]);
    // _urlImages = state.value!;
    // resetPosition();

    final List<String> postImages = await AuthMethods().postData();
    state = AsyncValue.data(postImages);
    _urlImages = state.value!;
    resetPosition();
  }

  void removeCard(String first) {
    return;
  }
}

void _showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';

import 'package:swipefit/resources/auth_methods.dart';

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
  ////////
  int _milliseconds = 400;
  int get milliseconds => _milliseconds;
  ////////
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  @override
  //FutureOr<List<String>> build() async {
  FutureOr<List<String>> build() {
    _urlImages = [
      // 'https://picsum.photos/id/1/720/1280.jpg',
      // 'https://picsum.photos/id/2/720/1280.jpg',
      // 'https://picsum.photos/id/31/720/1280.jpg',
      // 'https://picsum.photos/id/32/720/1280.jpg',
      // 'https://picsum.photos/id/33/720/1280.jpg',
    ];
    return _urlImages;
    // resetUsers();
    // return _urlImages;
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    _position = Offset.zero; /////////////
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;

    // Calculate the angle based on the horizontal movement
    _angle = 45 * x / _screenSize.width;

    // Ensure the milliseconds value is always positive
    _milliseconds = (400 - (_position.distance * 2).toInt()).clamp(1, 500);
  }

  void endPosition() {
    _isDragging = false;
    final status = getStatus(force: true);

    switch (status) {
      case CardStatus.like:
        like();
        ////////////////////////
        _position = Offset(_screenSize.width, 0);
        _angle = 0;
        //////////////////////////
        break;
      case CardStatus.dislike:
        dislike();
        ////////////////////////
        _position = Offset(_screenSize.width * -1, 0);
        _angle = 0;
        //////////////////////////
        break;
      case CardStatus.superLike:
        superLike();
        ////////////////////////
        _position = Offset(0, _screenSize.height * -1);
        _angle = 0;
        //////////////////////////
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _position = Offset.zero;
    _angle = 0;
    _isDragging = false;
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

    _showToast('Liked!');
    AuthMethods().likePost(_urlImages.last);
    nextCard();
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);

    _showToast('Disliked!');
    AuthMethods().dislikePost(_urlImages.last);
    nextCard();
  }

  void superLike() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    nextCard();
    _showToast('Super Liked!');
  }

  Future<void> nextCard() async {
    if (_urlImages.isEmpty) return;

    // await Future.delayed(Duration(milliseconds: 300));
    _urlImages.removeLast();
    await Future.delayed(Duration(milliseconds: 300));
    resetPosition();
    state =
        AsyncValue.data(_urlImages); // Update state with the remaining images
  }

  Future<void> resetUsers() async {
    // state = AsyncValue.data([
    //   'https://picsum.photos/id/1/720/1280.jpg',
    //   'https://picsum.photos/id/2/720/1280.jpg',
    //   'https://picsum.photos/id/31/720/1280.jpg',
    //   'https://picsum.photos/id/32/720/1280.jpg',
    //   'https://picsum.photos/id/33/720/1280.jpg',
    // ]);
    // _urlImages = state.value!;
    // resetPosition();

    final List<String> postImages = await AuthMethods().postData();
    state = AsyncValue.data(postImages);
    _urlImages = state.value!;
    resetPosition();
  }

  void removeCard(String first) {
    return;
  }
}

void _showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
