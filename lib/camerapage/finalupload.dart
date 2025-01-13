import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipefit/Pages/Send.dart';
import 'package:swipefit/storage/aiapi.dart';
import 'package:swipefit/storage/storage.dart';
import 'package:provider/provider.dart';

class FinalUpload extends StatefulWidget {
  static const routepage = "/finalupload";
  final String? imagepath;
  const FinalUpload({this.imagepath, super.key});

  @override
  State<FinalUpload> createState() => _FinalUploadState();
}

class _FinalUploadState extends State<FinalUpload> {
  final TryOnApiClient client = TryOnApiClient();

  File? _selectimage;
  String? _selectpath;
  int _selectedcloth = -1;
  bool uploaded = false;
  bool uploade = false;
  File? outputImage;
  File? maskedImage;
  String _selectname = '';

  List<String> l = [];
  List<String> l2 = [];
  List<String> images = [];
  List<File?> AI_Images = [];

  @override
  void initState() {
    super.initState();
    _selectpath = widget.imagepath!;
    print(_selectpath);
    _selectimage = File(_selectpath!);
    _selectname = "pic${DateTime.now().toIso8601String()}";
    AI_Images = [_selectimage].reversed.toList();
  }

  Future<void> runTryOn(uid) async {
    final storage = Provider.of<Storage>(context, listen: false);
    if (_selectimage == null || _selectedcloth == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both human and garment images')),
      );
      return;
    }

    setState(() {
      uploade = true;
    });

    try {
      print('Processing try-on request');
      print('Selected human image: ${_selectimage!.path}');
      print('Selected garment image: ${images[_selectedcloth]}');

      print('Try-on process completed successfully');

      // Future<http.Response> human = http.get(Uri.parse("$_selectimage"));

      Future<void> human =
          storage.upload_and_download(widget.imagepath!, uid).then((v) async {
        final Uri humanImage = Uri.parse(v!);
        outputImage = await client.generateVirtualTryOn(
            "$humanImage", images[_selectedcloth]);
        print("the output image is :$humanImage");
        print("the output link is :$v");
        setState(() {
          uploaded = true;
          uploade = false;
          AI_Images.add(outputImage);
          AI_Images = AI_Images.reversed.toList();
        });
      });
    } catch (e) {
      setState(() {
        uploade = false;
      });
      print('An error occurred during try-on: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    l = const ["S", "M", "L"];
    l2 = const ["Male", "Female", "For Everyone"];
    images = [
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F00962381807-e0.jpg?alt=media&token=8c1392ec-9fc8-485b-840f-2d030a6aa821',
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F01887450800-e1.jpg?alt=media&token=9065579a-1d09-49fa-868d-6c62776624cd',
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04090335807-e2.jpg?alt=media&token=8dd51ff3-528f-4c0a-a887-db78c8ad2f28',
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04393350800-e3.jpg?alt=media&token=10c99a3c-6154-49c5-ba0e-e19b3367baae',
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04805305251-e4.jpg?alt=media&token=cca33518-f5b0-424f-ac7c-475348902f28',
      'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F05679250401-e5.jpg?alt=media&token=b90c0efd-4c03-4003-8c9a-cc1fa3b67e08',
    ];

    final List<String> imageLink = [
      'https://www.zara.com/in/en/faded-hoodie-p00962381.html?v1=375210427',
      'https://www.zara.com/in/en/basic-heavy-weight-t-shirt-p01887450.html?v1=364113271',
      'https://www.zara.com/in/en/printed-knit-t-shirt-p04090335.html?v1=390672229',
      'https://www.zara.com/in/en/hoodie-p00761330.html?v1=381137893',
      'https://www.zara.com/in/en/spray-print-knit-t-shirt-p04805305.html?v1=365910331',
      'https://www.zara.com/in/en/abstract-print-shirt-p05679250.html?v1=372994197'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SwipeFit"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 2),
                        child: Container(
                          width: size.width,
                          height: size.height / 2.3,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 10, 10, 10),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: _selectimage == null
                              ? const Center(
                                  child: Text(
                                    "No Image Selected",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              : CarouselSlider.builder(
                                  itemCount: AI_Images.length,
                                  itemBuilder: (context, index, realIndex) =>
                                      ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      AI_Images[index]!,
                                      width: double.infinity,
                                    ),
                                  ),
                                  options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    height: size.height,
                                    enableInfiniteScroll: false,
                                    viewportFraction: 1.0,
                                  ),
                                ),
                        ),
                      ),
                      uploade == false
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(top: 25),
                              child: Uploading(
                                uploaded: uploaded,
                              ),
                            ),
                    ],
                  ),
                  DefaultTabController(
                    length: 1,
                    child: SizedBox(
                      height: size.height / 2.6,
                      width: size.width,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: AppBar(
                                backgroundColor: Colors.black,
                                bottom: const TabBar(
                                  indicatorColor: Colors.cyan,
                                  labelColor: Colors.cyan,
                                  unselectedLabelColor:
                                      Color.fromARGB(113, 255, 255, 255),
                                  tabs: [
                                    Tab(
                                      child: Text("Dress Details"),
                                    ),
                                  ],
                                )),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedcloth = index;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 10, 10, 10),
                                            border: Border.all(
                                                color: _selectedcloth == index
                                                    ? Colors.cyan
                                                    : Colors.black),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              images[index],
                                              width: size.width,
                                              height: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.imagepath == null
                              ? Container()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      runTryOn(snapshot.data!.uid);
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Try On",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Icon(
                                            Icons.try_sms_star,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          widget.imagepath == null
                              ? Container()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10, top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          Send.routepage,
                                          arguments: {
                                            "id": "true",
                                            "picname": _selectname,
                                            "pathname": outputImage!.path,
                                            'link': imageLink[_selectedcloth],
                                          });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Send",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Icon(
                                            Icons.send,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class OutFitDetails {
  final String link;
  final String heignt;
  final String size;
  final String Gender;
  OutFitDetails(this.Gender, this.link, this.heignt, this.size);
}

class Uploading extends StatefulWidget {
  final bool? uploaded;
  const Uploading({super.key, this.uploaded});

  @override
  State<Uploading> createState() => _UploadingState();
}

class _UploadingState extends State<Uploading> {
  // bool sent = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.cyan, borderRadius: BorderRadius.circular(20)),
            height: 40,
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Row(
                mainAxisAlignment: widget.uploaded == false
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: widget.uploaded == false
                        ? const Text(
                            "Uploading",
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            "Uploaded",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  widget.uploaded == false
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            value: widget.uploaded == false ? null : 0,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
