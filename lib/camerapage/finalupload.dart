// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:swipefit/Pages/Send.dart';
// import 'package:swipefit/main.dart';
// import 'package:swipefit/provider/provider.dart';
// import 'package:swipefit/resources/auth_methods.dart';
// import 'package:swipefit/storage/aiapi.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class FinalUpload extends ConsumerStatefulWidget {
//   static const routepage = "/finalupload";
//   final String? imagepath;
//   final Key key;
//   FinalUpload({this.imagepath, required this.key}); //: super(key: key);

//   @override
//   ConsumerState<FinalUpload> createState() => _FinalUploadState();
// }

// class _FinalUploadState extends ConsumerState<FinalUpload> {
//   final TryOnApiClient client = TryOnApiClient();

//   final TextEditingController _titleController = TextEditingController();
//   Map<String, bool> _selectedFriends = {};
//   List<String> _friends = [];

//   File? _selectimage = null;
//   String? _selectpath = null;
//   int _selectedcloth = -1;
//   bool uploaded = false;
//   bool uploade = false;
//   File? outputImage;
//   File? maskedImage;
//   String _selectname = '';
//   Map<String, dynamic>? result;
//   List<String> l = [];
//   List<String> l2 = [];
//   List<String> images = [];
//   List<File?> AI_Images = [];

//   Future<void> _sendImage(BuildContext context) async {
//     try {
//       // Ensure the image path is valid
//       if (widget.imagepath == null) {
//         throw Exception("Image path is null");
//       }

//       // Read the image file
//       final file = File(widget.imagepath!);
//       if (!file.existsSync()) {
//         throw Exception("Image file does not exist");
//       }

//       // Get the current date and time
//       final now = DateTime.now();
//       final formatter = DateFormat('yyyyMMdd_HHmmss');
//       final formattedDate = formatter.format(now);

//       // Define the storage path
//       final storagePath =
//           'pictures/${file.uri.pathSegments.last}_$formattedDate.jpg';

//       // Upload the image to Firebase storage in secondaryApp
//       final storageRef = FirebaseStorage.instanceFor(app: secondaryApp!)
//           .ref()
//           .child(storagePath);
//       final uploadTask = storageRef.putFile(file);
//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();

//       // Get the current user's UID
//       final currentUid = await AuthMethods().getCurrentUserId();

//       // Get the selected friends' UIDs
//       final selectedFriendsUids = _selectedFriends.entries
//           .where((entry) => entry.value)
//           .map((entry) => entry.key)
//           .toList();

//       // Perform addPost with the new URL, title, current UID, and selected friends' UIDs
//       await AuthMethods().addPost(
//         postImage: downloadUrl,
//         postTitle: _titleController.text,
//         postedBy: currentUid,
//         postedTo: selectedFriendsUids,
//       );

//       // Show success message or navigate to another page
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image uploaded successfully!')),
//       );
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//     }
//   }

//   void _showSendDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Send Image'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _titleController,
//                       decoration: InputDecoration(labelText: 'Title'),
//                     ),
//                     SizedBox(height: 20),
//                     Text('Select Friends:'),
//                     Container(
//                       height: 200, // Set a fixed height for the ListView
//                       width: double
//                           .maxFinite, // Ensure the ListView takes up the full width
//                       child: FutureBuilder<Map<String, String>>(
//                         future: AuthMethods().getUsernamesFromUids(_friends),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Center(child: CircularProgressIndicator());
//                           } else if (snapshot.hasError) {
//                             return Center(
//                                 child: Text('Error: ${snapshot.error}'));
//                           } else if (!snapshot.hasData ||
//                               snapshot.data!.isEmpty) {
//                             return Center(child: Text('No friends found'));
//                           } else {
//                             final friendsMap = snapshot.data!;
//                             return ListView(
//                               shrinkWrap: true,
//                               children: friendsMap.entries.map((entry) {
//                                 return CheckboxListTile(
//                                   title: Text(entry.key),
//                                   value: _selectedFriends[entry.value] ?? false,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       _selectedFriends[entry.value] =
//                                           value ?? false;
//                                     });
//                                   },
//                                 );
//                               }).toList(),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _sendImage(context);
//                   },
//                   child: Text('Send'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: Text('Final Upload'),
//   //     ),
//   //     body: Center(
//   //       child: ElevatedButton(
//   //         onPressed: () => _showSendDialog(context),
//   //         child: Text('Send'),
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   void initState() {
//     super.initState();
//     _selectpath = widget.imagepath!;
//     print(_selectpath);
//     _selectimage = File(_selectpath!);
//     _selectname = "pic${DateTime.now().toIso8601String()}";

//     AI_Images = [_selectimage].reversed.toList();
//     _fetchFriends();
//   }

//   Future<void> _fetchFriends() async {
//     final currentUid = await AuthMethods().getCurrentUserId();
//     final friends = await AuthMethods().fetchFriends(currentUid);
//     setState(() {
//       _friends = friends;
//     });
//   }

// /*
//   Future<void> runTryOn(uid) async {
//     outputImage = null;
//     //final storage = Provider.of<Storage>(context, listen: false);
//     if (_selectimage == null || _selectedcloth == -1) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select both human and garment images')),
//       );
//       return;
//     }

//     setState(() {
//       uploade = true;
//     });

//     try {
//       print('Processing try-on request');
//       print('Selected human image: ${_selectimage!.path}');
//       print('Selected garment image: ${images[_selectedcloth]}');

//       print('Try-on process completed successfully');

//       // Future<http.Response> human = http.get(Uri.parse("$_selectimage"));

//       /*Future<void> human =
//           storage.upload_and_download(widget.imagepath!, uid).then((v) async {
//         final Uri humanImage = Uri.parse(v!);
//         outputImage = await client.generateVirtualTryOn(
//             "$humanImage", images[_selectedcloth]);
//         print("the output image is :$humanImage");
//         print("the output link is :$v");
//         setState(() {
//           uploaded = true;
//           uploade = false;
//           AI_Images.add(outputImage);
//           AI_Images = AI_Images.reversed.toList();
//         });
//       });*/
//       Future<void> human = Future(() async {
//         final bytes = await _selectimage!.readAsBytes();
//         final base64Image = base64Encode(bytes);
//         final Uri humanImage = Uri.parse("data:image/jpeg;base64,$base64Image");
//         outputImage = await client.generateVirtualTryOn(
//             "$humanImage", images[_selectedcloth]);
//         setState(() {
//           uploaded = true;
//           uploade = false;
//           AI_Images.add(outputImage);
//           AI_Images = AI_Images.reversed.toList();
//         });
//       });
//     } catch (e) {
//       setState(() {
//         uploade = false;
//       });
//       print('An error occurred during try-on: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     } finally {
//       setState(() {});
//     }
//   }
// */

// ///////////////////////////
//   final loggerProvider = LoggerProvider();

//   void updateLogOutput() {
//     loggerProvider.updateLogOutput();
//   }

//   void printDownloadedUrl() {
//     final logOutput = loggerProvider.getLogOutput();
//     final regex = RegExp(r'Downloading output from: \s*(https?://[^\s]+)');
//     final match = regex.firstMatch(logOutput);

//     if (match != null) {
//       final downloadedUrl = match.group(1);
//       print('Downloaded URL: $downloadedUrl');
//     } else {
//       print('No URL found in the log output.');
//     }
//   }

//   void printLogs() {
//     final logOutput = loggerProvider.getLogOutput();
//     final lines = logOutput.split('\n');

//     for (final line in lines) {
//       print(line);
//     }
//   }

//   Future<void> generateOutput() async {
//     // Simulate generating output (replace with actual API call)
//     await Future.delayed(Duration(seconds: 10));
//   }
// ///////////////////////////////

//   Future<void> runTryOn(uid) async {
//     //final storage = Provider.of<Storage>(context, listen: false);
//     if (_selectimage == null || _selectedcloth == -1) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select both human and garment images')),
//       );
//       return;
//     }

//     setState(() {
//       uploade = true;
//     });

//     try {
//       print('Processing try-on request');
//       print('Selected human image: ${_selectimage!.path}');
//       print('Selected garment image: ${images[_selectedcloth]}');

//       print('Try-on process completed successfully');

//       // Future<http.Response> human = http.get(Uri.parse("$_selectimage"));

//       /*Future<void> human =
//           storage.upload_and_download(widget.imagepath!, uid).then((v) async {
//         final Uri humanImage = Uri.parse(v!);
//         outputImage = await client.generateVirtualTryOn(
//             "$humanImage", images[_selectedcloth]);
//         print("the output image is :$humanImage");
//         print("the output link is :$v");
//         setState(() {
//           uploaded = true;
//           uploade = false;
//           AI_Images.add(outputImage);
//           AI_Images = AI_Images.reversed.toList();
//         });
//       });*/

//       Future<void> human = Future(() async {
//         final bytes = await _selectimage!.readAsBytes();
//         final base64Image = base64Encode(bytes);
//         final Uri humanImage = Uri.parse("data:image/jpeg;base64,$base64Image");

//         // outputImage = await client.generateVirtualTryOn(
//         //     "$humanImage", images[_selectedcloth])["outputFile"];
//         final result = await client.generateVirtualTryOn(
//             "$humanImage", images[_selectedcloth]);
//         //outputImage = result!["outputFile"];

//         final outputUrl = await result?["outputUrl"];

//         setState(() {
//           uploaded = true;
//           uploade = false;
//           // AI_Images.add(outputImage);
//           //AI_Images.add(outputUrl);
//           AI_Images = AI_Images.reversed.toList();
//           this.result = result;
//           print(AI_Images);
//         });
//       });
//     } catch (e) {
//       setState(() {
//         uploade = false;
//       });
//       print('An error occurred during try-on: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     } finally {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authmethods = AuthMethods();
//     final size = MediaQuery.of(context).size;
//     l = const ["S", "M", "L"];
//     l2 = const ["Male", "Female", "For Everyone"];
//     final item_list = ref.watch(items_from_databaseProvider);

//     // images = [
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F00962381807-e0.jpg?alt=media&token=8c1392ec-9fc8-485b-840f-2d030a6aa821',
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F01887450800-e1.jpg?alt=media&token=9065579a-1d09-49fa-868d-6c62776624cd',
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04090335807-e2.jpg?alt=media&token=8dd51ff3-528f-4c0a-a887-db78c8ad2f28',
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04393350800-e3.jpg?alt=media&token=10c99a3c-6154-49c5-ba0e-e19b3367baae',
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04805305251-e4.jpg?alt=media&token=cca33518-f5b0-424f-ac7c-475348902f28',
//     //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F05679250401-e5.jpg?alt=media&token=b90c0efd-4c03-4003-8c9a-cc1fa3b67e08',
//     // ];

//     // final List<String> imageLink = [
//     //   'https://www.zara.com/in/en/faded-hoodie-p00962381.html?v1=375210427',
//     //   'https://www.zara.com/in/en/basic-heavy-weight-t-shirt-p01887450.html?v1=364113271',
//     //   'https://www.zara.com/in/en/printed-knit-t-shirt-p04090335.html?v1=390672229',
//     //   'https://www.zara.com/in/en/hoodie-p00761330.html?v1=381137893',
//     //   'https://www.zara.com/in/en/spray-print-knit-t-shirt-p04805305.html?v1=365910331',
//     //   'https://www.zara.com/in/en/abstract-print-shirt-p05679250.html?v1=372994197'
//     // ];
//     return item_list.when(
//       data: (items) {
//         images = items.map((item) => item['ItemImage'] as String).toList();
//         return Scaffold(
//           key: widget.key,
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             title: const Text("SwipeFit"),
//             backgroundColor: Colors.black,
//           ),
//           body: StreamBuilder<User?>(
//               stream: FirebaseAuth.instance.authStateChanges(),
//               builder: (context, snapshot) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Stack(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 10, right: 10, top: 2),
//                             child: Container(
//                               width: size.width,
//                               height: size.height / 2.3,
//                               decoration: const BoxDecoration(
//                                 color: Color.fromARGB(255, 10, 10, 10),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(20)),
//                               ),
//                               child: _selectimage == null
//                                   ? const Center(
//                                       child: Text(
//                                         "No Image Selected",
//                                         style: TextStyle(
//                                             fontSize: 20, color: Colors.grey),
//                                       ),
//                                     )
//                                   : CarouselSlider.builder(
//                                       itemCount: result == null
//                                           ? 1
//                                           : 2, //AI_Images.length,
//                                       // itemBuilder: (context, index, realIndex) =>
//                                       //     ClipRRect(
//                                       //   borderRadius: BorderRadius.circular(10),
//                                       //   child:

//                                       //       Image.file(
//                                       //           AI_Images[index]!,
//                                       //           width: double.infinity,
//                                       //         )

//                                       // ),
//                                       itemBuilder: (context, index, realIndex) {
//                                         if (result == null) {
//                                           return ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             child: Image.file(
//                                               File(_selectimage!.path),
//                                               width: double.infinity,
//                                             ),
//                                           );
//                                         } else {
//                                           if (index == 0) {
//                                             return ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               child: Image.network(
//                                                 result!["outputUrl"],
//                                                 width: double.infinity,
//                                               ),
//                                             );
//                                           } else {
//                                             return ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               child: Image.file(
//                                                 File(_selectimage!.path),
//                                                 width: double.infinity,
//                                               ),
//                                             );
//                                           }
//                                         }
//                                       },

//                                       options: CarouselOptions(
//                                         enlargeCenterPage: true,
//                                         height: size.height,
//                                         enableInfiniteScroll: false,
//                                         viewportFraction: 1.0,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           uploade == false
//                               ? Container()
//                               : Padding(
//                                   padding: const EdgeInsets.only(top: 25),
//                                   child: Uploading(
//                                     uploaded: uploaded,
//                                   ),
//                                 ),
//                         ],
//                       ),
//                       DefaultTabController(
//                         length: 1,
//                         child: SizedBox(
//                           height: size.height / 2.6,
//                           width: size.width,
//                           child: Column(
//                             children: [
//                               SizedBox(
//                                 height: 50,
//                                 child: AppBar(
//                                     backgroundColor: Colors.black,
//                                     bottom: const TabBar(
//                                       indicatorColor: Colors.grey,
//                                       labelColor: Colors.grey,
//                                       unselectedLabelColor:
//                                           Color.fromARGB(113, 255, 255, 255),
//                                       tabs: [
//                                         Tab(
//                                           child: Text("Dress Details"),
//                                         ),
//                                       ],
//                                     )),
//                               ),
//                               Expanded(
//                                 child: TabBarView(
//                                   children: [
//                                     GridView.builder(
//                                       gridDelegate:
//                                           const SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 2,
//                                         mainAxisSpacing: 8.0,
//                                         crossAxisSpacing: 8.0,
//                                       ),
//                                       padding: const EdgeInsets.all(8.0),
//                                       itemCount: //images.length,
//                                           item_list.maybeWhen(
//                                         data: (items) => items.length,
//                                         orElse: () => 0,
//                                       ),
//                                       // itemBuilder: (context, index) {
//                                       //   return GestureDetector(
//                                       //     onTap: () {
//                                       //       setState(() {
//                                       //         _selectedcloth = index;
//                                       //       });
//                                       //     },
//                                       //     child: Container(
//                                       //       decoration: BoxDecoration(
//                                       //           color: const Color.fromARGB(
//                                       //               255, 10, 10, 10),
//                                       //           border: Border.all(
//                                       //               color: _selectedcloth == index
//                                       //                   ? Colors.grey
//                                       //                   : Colors.black),
//                                       //           borderRadius:
//                                       //               const BorderRadius.all(
//                                       //                   Radius.circular(5))),
//                                       //       child: Center(
//                                       //         child: ClipRRect(
//                                       //           borderRadius:
//                                       //               BorderRadius.circular(10),
//                                       //           child: Image.network(
//                                       //             images[index],
//                                       //             width: size.width,
//                                       //             height: double.infinity,
//                                       //           ),
//                                       //         ),
//                                       //       ),
//                                       //     ),
//                                       //   );
//                                       // },
//                                       itemBuilder: (context, index) {
//                                         return item_list.when(
//                                           data: (items) {
//                                             final imageUrl =
//                                                 items[index]['ItemImage'] ?? '';
//                                             return GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   _selectedcloth = index;
//                                                 });
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   color: const Color.fromARGB(
//                                                       255, 10, 10, 10),
//                                                   border: Border.all(
//                                                     color:
//                                                         _selectedcloth == index
//                                                             ? Colors.grey
//                                                             : Colors.black,
//                                                   ),
//                                                   borderRadius:
//                                                       const BorderRadius.all(
//                                                           Radius.circular(10)),
//                                                 ),
//                                                 child: Center(
//                                                   child: ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     child: Image.network(
//                                                       imageUrl,
//                                                       width: size.width,
//                                                       height: double.infinity,
//                                                       //fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           loading: () => const Center(
//                                               child:
//                                                   CircularProgressIndicator()),
//                                           error: (err, stack) => Center(
//                                               child: Text('Error: $err')),
//                                         );
//                                       },
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: SizedBox(
//                           width: size.width,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               widget.imagepath == null
//                                   ? Container()
//                                   : Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 10, top: 5),
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           runTryOn(snapshot.data!.uid);
//                                         },
//                                         child: Container(
//                                           height: 35,
//                                           width: 90,
//                                           decoration: BoxDecoration(
//                                               color: Colors.grey[800],
//                                               borderRadius:
//                                                   BorderRadius.circular(20)),
//                                           child: const Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Text(
//                                                 "Try On",
//                                                 style: TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                               Icon(
//                                                 Icons.try_sms_star,
//                                                 color: Colors.white,
//                                                 size: 20,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                               widget.imagepath == null
//                                   ? Container()
//                                   : Padding(
//                                       padding: const EdgeInsets.only(
//                                           right: 10, top: 5),
//                                       child: GestureDetector(
//                                         onTap: () async {
//                                           // Navigator.of(context).pushNamed(
//                                           //     Send.routepage,
//                                           //     arguments: {
//                                           //       "id": "true",
//                                           //       "picname": _selectname,
//                                           //       "pathname": outputImage!.path,
//                                           //       'link': imageLink[_selectedcloth],
//                                           //     });

//                                           //////////////////////////

//                                           _showSendDialog(context);

//                                           ////////////
//                                         },
//                                         child: Container(
//                                           height: 35,
//                                           width: 90,
//                                           decoration: BoxDecoration(
//                                               color: Colors.grey[800],
//                                               borderRadius:
//                                                   BorderRadius.circular(20)),
//                                           child: const Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Text(
//                                                 "Send",
//                                                 style: TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                               Icon(
//                                                 Icons.send,
//                                                 color: Colors.white,
//                                                 size: 20,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (err, stack) => Center(child: Text('Error: $err')),
//     );
//     ////////////
//   }
// }

// class OutFitDetails {
//   final String link;
//   final String heignt;
//   final String size;
//   final String Gender;
//   OutFitDetails(this.Gender, this.link, this.heignt, this.size);
// }

// class Uploading extends StatefulWidget {
//   final bool? uploaded;
//   const Uploading({super.key, this.uploaded});

//   @override
//   State<Uploading> createState() => _UploadingState();
// }

// class _UploadingState extends State<Uploading> {
//   // bool sent = false;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 10),
//           child: Container(
//             decoration: BoxDecoration(
//                 color: Colors.cyan, borderRadius: BorderRadius.circular(20)),
//             height: 40,
//             width: 100,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 0),
//               child: Row(
//                 mainAxisAlignment: widget.uploaded == false
//                     ? MainAxisAlignment.spaceAround
//                     : MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 0),
//                     child: widget.uploaded == false
//                         ? const Text(
//                             "Uploading",
//                             style: TextStyle(color: Colors.white),
//                           )
//                         : const Text(
//                             "Uploaded",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                   ),
//                   widget.uploaded == false
//                       ? SizedBox(
//                           height: 15,
//                           width: 15,
//                           child: CircularProgressIndicator(
//                             value: widget.uploaded == false ? null : 0,
//                           ),
//                         )
//                       : Container()
//                 ],
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }

// class LoggerProvider with ChangeNotifier {
//   String _logOutput = '';

//   String getLogOutput() {
//     return _logOutput;
//   }

//   void updateLogOutput() {
//     log('Log output:');
//     _logOutput = 'Log output:';
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipefit/Pages/Send.dart';
import 'package:swipefit/main.dart';
import 'package:swipefit/provider/provider.dart';
import 'package:swipefit/resources/auth_methods.dart';
import 'package:swipefit/storage/aiapi.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FinalUpload extends ConsumerStatefulWidget {
  static const routepage = "/finalupload";
  final String? imagepath;
  final Key key;
  FinalUpload({this.imagepath, required this.key}); //: super(key: key);

  @override
  ConsumerState<FinalUpload> createState() => _FinalUploadState();
}

class _FinalUploadState extends ConsumerState<FinalUpload> {
  final TryOnApiClient client = TryOnApiClient();

  final TextEditingController _titleController = TextEditingController();
  Map<String, bool> _selectedFriends = {};
  List<String> _friends = [];

  File? _selectimage = null;
  String? _selectpath = null;
  int _selectedcloth = -1;
  bool uploaded = false;
  bool uploade = false;
  File? outputImage;
  File? maskedImage;
  String _selectname = '';
  Map<String, dynamic>? result;
  List<String> l = [];
  List<String> l2 = [];
  List<String> images = [];
  List<File?> AI_Images = [];

  Future<void> _sendImage(BuildContext context) async {
    try {
      // Ensure the generated image is valid
      if (outputImage == null) {
        throw Exception("Generated image is null");
      }

      // Get the current date and time
      final now = DateTime.now();
      final formatter = DateFormat('yyyyMMdd_HHmmss');
      final formattedDate = formatter.format(now);

      // Define the storage path
      final storagePath =
          'pictures/${outputImage!.path.split('/').last}_$formattedDate.jpg';

      // Upload the generated image to Firebase storage in secondaryApp
      final storageRef = FirebaseStorage.instanceFor(app: secondaryApp!)
          .ref()
          .child(storagePath);
      final uploadTask = storageRef.putFile(outputImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Get the current user's UID
      final currentUid = await AuthMethods().getCurrentUserId();

      // Get the selected friends' UIDs
      final selectedFriendsUids = _selectedFriends.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Perform addPost with the new URL, title, current UID, and selected friends' UIDs
      await AuthMethods().addPost(
        postImage: downloadUrl,
        postTitle: _titleController.text,
        postedBy: currentUid,
        postedTo: selectedFriendsUids,
      );

      // Show success message or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _showSendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Send Image'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    SizedBox(height: 20),
                    Text('Select Friends:'),
                    Container(
                      height: 200, // Set a fixed height for the ListView
                      width: double
                          .maxFinite, // Ensure the ListView takes up the full width
                      child: FutureBuilder<Map<String, String>>(
                        future: AuthMethods().getUsernamesFromUids(_friends),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No friends found'));
                          } else {
                            final friendsMap = snapshot.data!;
                            return ListView(
                              shrinkWrap: true,
                              children: friendsMap.entries.map((entry) {
                                return CheckboxListTile(
                                  title: Text(entry.key),
                                  value: _selectedFriends[entry.value] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedFriends[entry.value] =
                                          value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sendImage(context);
                  },
                  child: Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Final Upload'),
  //     ),
  //     body: Center(
  //       child: ElevatedButton(
  //         onPressed: () => _showSendDialog(context),
  //         child: Text('Send'),
  //       ),
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _selectpath = widget.imagepath!;
    print(_selectpath);
    _selectimage = File(_selectpath!);
    _selectname = "pic${DateTime.now().toIso8601String()}";

    AI_Images = [_selectimage].reversed.toList();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final currentUid = await AuthMethods().getCurrentUserId();
    final friends = await AuthMethods().fetchFriends(currentUid);
    setState(() {
      _friends = friends;
    });
  }

/*
  Future<void> runTryOn(uid) async {
    outputImage = null;
    //final storage = Provider.of<Storage>(context, listen: false);
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

      /*Future<void> human =
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
      });*/
      Future<void> human = Future(() async {
        final bytes = await _selectimage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        final Uri humanImage = Uri.parse("data:image/jpeg;base64,$base64Image");
        outputImage = await client.generateVirtualTryOn(
            "$humanImage", images[_selectedcloth]);
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
    } finally {
      setState(() {});
    }
  }
*/

///////////////////////////
  final loggerProvider = LoggerProvider();

  void updateLogOutput() {
    loggerProvider.updateLogOutput();
  }

  void printDownloadedUrl() {
    final logOutput = loggerProvider.getLogOutput();
    final regex = RegExp(r'Downloading output from: \s*(https?://[^\s]+)');
    final match = regex.firstMatch(logOutput);

    if (match != null) {
      final downloadedUrl = match.group(1);
      print('Downloaded URL: $downloadedUrl');
    } else {
      print('No URL found in the log output.');
    }
  }

  void printLogs() {
    final logOutput = loggerProvider.getLogOutput();
    final lines = logOutput.split('\n');

    for (final line in lines) {
      print(line);
    }
  }

  Future<void> generateOutput() async {
    // Simulate generating output (replace with actual API call)
    await Future.delayed(Duration(seconds: 10));
  }
///////////////////////////////

  Future<void> runTryOn(uid) async {
    //final storage = Provider.of<Storage>(context, listen: false);
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

      /*Future<void> human =
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
      });*/

      Future<void> human = Future(() async {
        final bytes = await _selectimage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        final Uri humanImage = Uri.parse("data:image/jpeg;base64,$base64Image");

        // outputImage = await client.generateVirtualTryOn(
        //     "$humanImage", images[_selectedcloth])["outputFile"];
        final result = await client.generateVirtualTryOn(
            "$humanImage", images[_selectedcloth]);
        //outputImage = result!["outputFile"];

        final outputUrl = await result?["outputUrl"];

        if (outputUrl == null) {
          throw Exception("Failed to generate output image");
        }

        print('Output URL: $outputUrl');

        // Save the generated image to a file
        final response = await http.get(Uri.parse(outputUrl));
        if (response.statusCode != 200) {
          throw Exception("Failed to download generated image");
        }

        final documentDirectory = await getApplicationDocumentsDirectory();
        outputImage = File('${documentDirectory.path}/generated_image.jpg');
        outputImage!.writeAsBytesSync(response.bodyBytes);

        print('Generated image saved at: ${outputImage!.path}');

        setState(() {
          uploaded = true;
          uploade = false;
          // AI_Images.add(outputImage);
          //AI_Images.add(outputUrl);
          AI_Images = AI_Images.reversed.toList();
          this.result = result;
          print(AI_Images);
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
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authmethods = AuthMethods();
    final size = MediaQuery.of(context).size;
    l = const ["S", "M", "L"];
    l2 = const ["Male", "Female", "For Everyone"];
    final item_list = ref.watch(items_from_databaseProvider);

    // images = [
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F00962381807-e0.jpg?alt=media&token=8c1392ec-9fc8-485b-840f-2d030a6aa821',
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F01887450800-e1.jpg?alt=media&token=9065579a-1d09-49fa-868d-6c62776624cd',
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04090335807-e2.jpg?alt=media&token=8dd51ff3-528f-4c0a-a887-db78c8ad2f28',
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04393350800-e3.jpg?alt=media&token=10c99a3c-6154-49c5-ba0e-e19b3367baae',
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04805305251-e4.jpg?alt=media&token=cca33518-f5b0-424f-ac7c-475348902f28',
    //   'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F05679250401-e5.jpg?alt=media&token=b90c0efd-4c03-4003-8c9a-cc1fa3b67e08',
    // ];

    // final List<String> imageLink = [
    //   'https://www.zara.com/in/en/faded-hoodie-p00962381.html?v1=375210427',
    //   'https://www.zara.com/in/en/basic-heavy-weight-t-shirt-p01887450.html?v1=364113271',
    //   'https://www.zara.com/in/en/printed-knit-t-shirt-p04090335.html?v1=390672229',
    //   'https://www.zara.com/in/en/hoodie-p00761330.html?v1=381137893',
    //   'https://www.zara.com/in/en/spray-print-knit-t-shirt-p04805305.html?v1=365910331',
    //   'https://www.zara.com/in/en/abstract-print-shirt-p05679250.html?v1=372994197'
    // ];
    return item_list.when(
      data: (items) {
        images = items.map((item) => item['ItemImage'] as String).toList();
        return Scaffold(
          key: widget.key,
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
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 2),
                            child: Container(
                              width: size.width,
                              height: size.height / 2.3,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 10, 10, 10),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
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
                                      itemCount: result == null
                                          ? 1
                                          : 2, //AI_Images.length,
                                      // itemBuilder: (context, index, realIndex) =>
                                      //     ClipRRect(
                                      //   borderRadius: BorderRadius.circular(10),
                                      //   child:

                                      //       Image.file(
                                      //           AI_Images[index]!,
                                      //           width: double.infinity,
                                      //         )

                                      // ),
                                      itemBuilder: (context, index, realIndex) {
                                        if (result == null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(_selectimage!.path),
                                              width: double.infinity,
                                            ),
                                          );
                                        } else {
                                          if (index == 0) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                result!["outputUrl"],
                                                width: double.infinity,
                                              ),
                                            );
                                          } else {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                File(_selectimage!.path),
                                                width: double.infinity,
                                              ),
                                            );
                                          }
                                        }
                                      },

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
                                      indicatorColor: Colors.grey,
                                      labelColor: Colors.grey,
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
                                      itemCount: //images.length,
                                          item_list.maybeWhen(
                                        data: (items) => items.length,
                                        orElse: () => 0,
                                      ),
                                      // itemBuilder: (context, index) {
                                      //   return GestureDetector(
                                      //     onTap: () {
                                      //       setState(() {
                                      //         _selectedcloth = index;
                                      //       });
                                      //     },
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //           color: const Color.fromARGB(
                                      //               255, 10, 10, 10),
                                      //           border: Border.all(
                                      //               color: _selectedcloth == index
                                      //                   ? Colors.grey
                                      //                   : Colors.black),
                                      //           borderRadius:
                                      //               const BorderRadius.all(
                                      //                   Radius.circular(5))),
                                      //       child: Center(
                                      //         child: ClipRRect(
                                      //           borderRadius:
                                      //               BorderRadius.circular(10),
                                      //           child: Image.network(
                                      //             images[index],
                                      //             width: size.width,
                                      //             height: double.infinity,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   );
                                      // },
                                      itemBuilder: (context, index) {
                                        return item_list.when(
                                          data: (items) {
                                            final imageUrl =
                                                items[index]['ItemImage'] ?? '';
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
                                                    color:
                                                        _selectedcloth == index
                                                            ? Colors.grey
                                                            : Colors.black,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: size.width,
                                                      height: double.infinity,
                                                      //fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (err, stack) => Center(
                                              child: Text('Error: $err')),
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
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 5),
                                      child: GestureDetector(
                                        onTap: () {
                                          runTryOn(snapshot.data!.uid);
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "Try On",
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 5),
                                      child: GestureDetector(
                                        onTap: () async {
                                          // Navigator.of(context).pushNamed(
                                          //     Send.routepage,
                                          //     arguments: {
                                          //       "id": "true",
                                          //       "picname": _selectname,
                                          //       "pathname": outputImage!.path,
                                          //       'link': imageLink[_selectedcloth],
                                          //     });

                                          //////////////////////////

                                          _showSendDialog(context);

                                          ////////////
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
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
                );
              }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
    ////////////
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

class LoggerProvider with ChangeNotifier {
  String _logOutput = '';

  String getLogOutput() {
    return _logOutput;
  }

  void updateLogOutput() {
    log('Log output:');
    _logOutput = 'Log output:';
    notifyListeners();
  }
}
