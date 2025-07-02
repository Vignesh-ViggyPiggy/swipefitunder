/*
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:swipefit/Provider/Provider.dart';
import 'package:swipefit/camerapage/finalupload.dart';

class UploadPage2 extends ConsumerStatefulWidget {
  static const routepage = "/demoupload";
  final String? imagepath;
  const UploadPage2({this.imagepath, super.key});

  @override
  ConsumerState<UploadPage2> createState() => _UploadPage2State();
}

class _UploadPage2State extends ConsumerState<UploadPage2> {
  File? _selectedImage;
  String? _selectedPath;
  String? _selectedName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.imagepath != null && widget.imagepath!.isNotEmpty) {
        File? croppedFile = await cropImage(widget.imagepath!);
        if (croppedFile != null) {
          setState(() {
            _selectedPath = croppedFile.path;
            _selectedImage = croppedFile;
            _selectedName = "pic${DateTime.now().toIso8601String()}";
          });
        } else {
          // Handle cropping cancellation
          Navigator.of(context).pop();
        }
      } else {
        // If no image path is provided, navigate back or show a message
        Navigator.of(context).pop();
      }
    });
  }

  Future<File?> cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.deepOrange,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          color: Colors.black,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: widget.imagepath == null
                              ? const Center(
                                  child: Text(
                                    "Image not Found",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              : Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.imagepath == null
                                    ? Container()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (snapshot.data?.uid != null) {
                                              ref
                                                  .read(uploadProvider.notifier)
                                                  .uploadImage(
                                                _selectedName!,
                                                _selectedPath!,
                                                snapshot.data!.uid,
                                                (name, data, uid) async {
                                                  // Your uploadServer implementation
                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 1));
                                                },
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: Colors.cyan,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: uploadState.when(
                                              data: (state) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text(
                                                    "Upload",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Icon(
                                                    state.isUploading
                                                        ? Icons.cloud_upload
                                                        : Icons.upload_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                              loading: () => const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "Uploading",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ],
                                              ),
                                              error: (e, stackTrace) =>
                                                  const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                widget.imagepath == null
                                    ? Container()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              '/send', // Your Send route
                                              arguments: {
                                                "id": "true",
                                                "picname": _selectedName,
                                                "pathname": _selectedPath,
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.cyan,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Send",
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                    uploadState.when(
                      data: (state) => state.isUploading
                          ? const Padding(
                              padding: EdgeInsets.only(top: 25),
                              child: Uploading(uploaded: false),
                            )
                          : Container(),
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Uploading(uploaded: false),
                      ),
                      error: (e, stackTrace) => Container(), // Handle error UI
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:swipefit/Provider/Provider.dart';
import 'package:swipefit/camerapage/finalupload.dart';

class UploadPage2 extends ConsumerStatefulWidget {
  static const routepage = "/demoupload";
  final String? imagepath;
  const UploadPage2({this.imagepath, super.key});

  @override
  ConsumerState<UploadPage2> createState() => _UploadPage2State();
}

class _UploadPage2State extends ConsumerState<UploadPage2> {
  File? _selectedImage;
  String? _selectedPath;
  String? _selectedName;

  bool _isLoading = false;

  @override
  // void dispose() {
  //   _selectedImage?.delete();
  //   _selectedImage = null;
  //   _selectedName = null;
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      if (widget.imagepath != null && widget.imagepath!.isNotEmpty) {
        File? croppedFile = await cropImage(widget.imagepath!);

        setState(() {
          _isLoading = false;
        });

        if (croppedFile != null) {
          setState(() {
            _selectedPath = croppedFile.path;
            _selectedImage = croppedFile;
            _selectedName = "pic${DateTime.now().toIso8601String()}";
          });
        } else {
          // Handle cropping cancellation
          Navigator.of(context).pop();
        }
      } else {
        // If no image path is provided, navigate back or show a message
        Navigator.of(context).pop();
      }
    });
  }

  Future<File?> cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.grey[900],
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.grey[900],
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],

          //statusBarColor: Colors.deepOrange,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.bottomStart,
                            children: [
                              Container(
                                color: Colors.black,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: widget.imagepath == null
                                    ? const Center(
                                        child: Text(
                                          "Image not Found",
                                          style: TextStyle(
                                              fontSize: 20, color: Colors.grey),
                                        ),
                                      )
                                    :
                                    // Image.file(
                                    //     _selectedImage!,
                                    //     fit: BoxFit.cover,
                                    //     width: double.infinity,
                                    //   ),

                                    //////////////////////
                                    FittedBox(
                                        fit: BoxFit.contain,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image.file(_selectedImage!),
                                        ),
                                      )

                                /////////////////////
                                // FittedBox(
                                //     fit: BoxFit.contain,
                                //     child: Image.file(
                                //       _selectedImage!,
                                //       fit: BoxFit.contain,

                                //     ),
                                //   )
                                ,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      widget.imagepath == null
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (snapshot.data?.uid !=
                                                      null) {
                                                    /*
                                              ref
                                                  .read(uploadProvider.notifier)
                                                  .uploadImage(
                                                _selectedName!,
                                                _selectedPath!,
                                                snapshot.data!.uid,
                                                (name, data, uid) async {
                                                  // Your uploadServer implementation
                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 1));
                                                },
                                              );
                                           */
                                                    // uploading(snapshot, storage,
                                                    //     uploadserver);
                                                    await Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FinalUpload(
                                                          imagepath:
                                                              _selectedPath,
                                                          key: UniqueKey(),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  height: 35,
                                                  width: 90,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: uploadState.when(
                                                    data: (state) => Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        const Text(
                                                          "Upload",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Icon(
                                                          state.isUploading
                                                              ? Icons
                                                                  .cloud_upload
                                                              : Icons
                                                                  .upload_rounded,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                    loading: () => const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          "Uploading",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                          width: 15,
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ],
                                                    ),
                                                    error: (e, stackTrace) =>
                                                        const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          "Error",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      widget.imagepath == null
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    '/send', // Your Send route
                                                    arguments: {
                                                      "id": "true",
                                                      "picname": _selectedName,
                                                      "pathname": _selectedPath,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: 35,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "Send",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
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
                          uploadState.when(
                            data: (state) => state.isUploading
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 25),
                                    child: Uploading(uploaded: false),
                                  )
                                : Container(),
                            loading: () => const Padding(
                              padding: EdgeInsets.only(top: 25),
                              child: Uploading(uploaded: false),
                            ),
                            error: (e, stackTrace) =>
                                Container(), // Handle error UI
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
