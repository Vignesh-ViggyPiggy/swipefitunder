import 'package:camera/camera.dart';
// import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'demoupload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:flutter_application_1/pages/Multiupload.dart';
// import 'package:flutter_application_1/pages/demoupload.dart';
// import 'package:flutter_application_1/pages/final_upload_multiple.dart';

// late List<CameraDescription> _cameras;

class CameraApp extends StatefulWidget {
  /// Default Constructor
  final List? camera;
  const CameraApp({this.camera, super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double total = 1.0;
  int cam = 0;
  bool run = false;
  FlashMode? _currentFlashMode;
  bool flashon = false;
  bool showfocus = false;
  double start = 0.1;
  double y = 0.1;

  @override
  void initState() {
    super.initState();
    camer();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void camer() {
    controller = CameraController(widget.camera![cam], ResolutionPreset.high);
    _currentFlashMode = controller.value.flashMode;
    _initializeControllerFuture = controller.initialize();
    _initializeControllerFuture.then((_) {
      if (!mounted) {
        return;
      }
      controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
      controller.getMinZoomLevel().then((value) => _minAvailableZoom = value);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller.setExposurePoint(offset);
    controller.setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    print(flashon);
    if (run == true) {
      camer();
      run = false;
    }
    final size = MediaQuery.of(context).size;
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Stack(alignment: Alignment(start, y), children: [
      Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Stack(alignment: AlignmentDirectional.centerEnd, children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                GestureDetector(
              onTapDown: (details) {
                onViewFinderTap(details, constraints);
              },
              onLongPressMoveUpdate: (details) async {
                double y = details.globalPosition.scale(0.013, 0.013).dy;

                if ((y <= _maxAvailableZoom && y >= _minAvailableZoom) &&
                    (total <= _maxAvailableZoom &&
                        total >= _minAvailableZoom)) {
                  setState(() {
                    _currentZoomLevel = y;
                    total = _maxAvailableZoom - y;
                  });
                  // print(total);
                  if (total <= _maxAvailableZoom &&
                      total >= _minAvailableZoom) {
                    await controller.setZoomLevel(total);
                  } else {
                    if (total > _maxAvailableZoom) {
                      // await controller.setZoomLevel(_maxAvailableZoom);
                      setState(() {
                        total = _maxAvailableZoom;
                      });
                    } else {
                      // await controller.setZoomLevel(_minAvailableZoom);
                      setState(() {
                        total = _minAvailableZoom;
                      });
                    }
                  }
                  // await controller.setZoomLevel(total);
                } else {
                  return;
                }
              },
              child: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: CameraPreview(controller)),
            ),
          ),
        ]),
        SizedBox(
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: size.height / 20,
                height: size.height / 20,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(0, 255, 255, 255), width: 1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                    onPressed: () async {
                      Future<XFile?> imagepick() async {
                        final XFile? image = await ImagePicker().pickImage(
                          maxWidth: 600,
                          source: ImageSource.gallery,
                        );
                        return image;
                      }

                      imagepick().then((img) async => {
                            if (img != null)
                              {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UploadPage2(
                                      imagepath: img.path,
                                    ),
                                  ),
                                )
                              }
                          });
                    },
                    icon: const Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.white,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      // Initialize camera controller and capture image
                      await _initializeControllerFuture;
                      final image = await controller.takePicture();

                      // Use Image Cropper to crop the captured image
                      CroppedFile? croppedFile = await ImageCropper().cropImage(
                        sourcePath: image.path,
                        aspectRatio:
                            const CropAspectRatio(ratioX: 3, ratioY: 4),
                        uiSettings: [
                          AndroidUiSettings(
                            toolbarTitle: 'Crop Image',
                            toolbarColor: Colors.cyan,
                            toolbarWidgetColor: Colors.white,
                            lockAspectRatio: true,
                            aspectRatioPresets: [
                              CropAspectRatioPreset.ratio4x3,
                            ],
                          ),
                        ],
                      );

                      // Check if cropping was successful
                      if (croppedFile != null) {
                        // Navigate to the upload page with the cropped image path
                        if (!mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UploadPage2(
                              imagepath: croppedFile.path,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error capturing or cropping image: $e");
                    }
                  },
                  child: Container(
                    width: size.height / 9,
                    height: size.height / 9,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(child: SizedBox()),
                  ),
                ),
              ),
              Container(
                width: size.height / 20,
                height: size.height / 20,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(0, 255, 255, 255), width: 1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: IconButton(
                      onPressed: (() {
                        if (cam == 0) {
                          print("1");
                          setState(() {
                            cam = 1;
                            run = true;
                          });
                        } else {
                          print("0");
                          setState(() {
                            cam = 0;
                            run = true;
                          });
                        }
                      }),
                      icon: const Icon(
                        Icons.switch_camera_rounded,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        )
      ]),
      showfocus == false
          ? Container()
          : Container(
              color: Colors.red,
              height: 50,
              width: 50,
            )
    ]);
  }
}
