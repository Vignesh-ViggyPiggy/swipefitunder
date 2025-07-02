import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';

final exploreCardProvider =
    AsyncNotifierProvider<ExploreCardNotifier, List<String>>(
  ExploreCardNotifier.new,
);

enum CardStatus { like, dislike, superLike }

class ExploreCardNotifier extends AsyncNotifier<List<String>> {
  List<String> _urlImages = [];
  bool _isDragging = false;
  Offset _position = Offset.zero;
  double _angle = 0;
  Size _screenSize = Size.zero;
  int _milliseconds = 400;
  int get milliseconds => _milliseconds;
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  @override
  FutureOr<List<String>> build() {
    _urlImages = [
      'https://thefoomer.in/cdn/shop/files/jpeg-optimizer_PATP0957.jpg?v=1707303883&width=3719',
      'https://frenchcrown.in/cdn/shop/files/13009-BLK_2_2c1f7929-4592-4379-a097-84ff19720ae2.jpg?v=1744027541&width=3500',
      'https://assets.myntassets.com/w_412,q_60,dpr_2,fl_progressive/assets/images/2420098/2018/2/19/11519043979762-Roadster-Women-Maroon--Navy-Blue-Regular-Fit-Checked-Casual-Shirt-8091519043979495-1.jpg',
      'https://assets.ajio.com/medias/sys_master/root/20240712/FHvR/66905aec6f60443f31eba9f4/-473Wx593H-700183905-pink-MODEL.jpg',
      'https://sassafras.in/cdn/shop/products/MSSHRT20171-1_1800x.jpg?v=1746857820',
    ];
    return _urlImages;
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    _position = Offset.zero;
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;

    // Calculate the angle based on the horizontal movement
    _angle = 45 * x / _screenSize.width;
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

    nextCard();
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);

    _showToast('Disliked!');

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
    //resetPosition();
    _urlImages.removeLast();
    await Future.delayed(Duration(milliseconds: 500));

    resetPosition();
    state = AsyncValue.data(_urlImages);
    // Update state with the remaining images
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> resetUsers() async {
    state = AsyncValue.data([
      'https://thefoomer.in/cdn/shop/files/jpeg-optimizer_PATP0957.jpg?v=1707303883&width=3719',
      'https://frenchcrown.in/cdn/shop/files/13009-BLK_2_2c1f7929-4592-4379-a097-84ff19720ae2.jpg?v=1744027541&width=3500',
      'https://assets.myntassets.com/w_412,q_60,dpr_2,fl_progressive/assets/images/2420098/2018/2/19/11519043979762-Roadster-Women-Maroon--Navy-Blue-Regular-Fit-Checked-Casual-Shirt-8091519043979495-1.jpg',
      'https://assets.ajio.com/medias/sys_master/root/20240712/FHvR/66905aec6f60443f31eba9f4/-473Wx593H-700183905-pink-MODEL.jpg',
      'https://sassafras.in/cdn/shop/products/MSSHRT20171-1_1800x.jpg?v=1746857820',
    ]);
    _urlImages = state.value!;
    resetPosition();

    // final List<String> postImages = await AuthMethods().postData();
    // state = AsyncValue.data(postImages);
    // _urlImages = state.value!;
    // resetPosition();
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
