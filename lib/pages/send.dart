import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:swipefit/storage/storage.dart';
import 'package:swipefit/widgets/sendprofile.dart';

class Send extends StatefulWidget {
  static const routepage = "/Send";
  const Send({super.key});

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  String? name;
  String? user_name;
  String? uid;
  List sendlist = [];
  bool length = false;
  bool sending = false;
  bool sen = false;

  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final Storage serverstorage = Storage();

  @override
  void initState() {
    FirebaseAuth.instance
        .authStateChanges()
        .first
        .asStream()
        // ignore: void_checks
        .forEach((element) {
      // print(element.uid);
      FirebaseFirestore.instance
          .collection("users")
          .doc(element?.uid)
          .snapshots()
          .listen((event) {
        setState(() {
          uid = element?.uid.toString();
          name = event.data()!["name"];
          user_name = event.data()!["user_name"];
        });
      });
    });
    super.initState();
  }

  // Future<void> sent_url_firestore(String picName, String uid) async {
  //   try {
  //     sendlist.forEach((element) async {
  //       var str = await storage
  //           .ref()
  //           .child('pics/$uid/$picName')
  //           .getDownloadURL()
  //           .then((value) async {
  //         String picUrl = value;
  //         var namedata =
  //             FirebaseFirestore.instance.collection("users").doc(uid);
  //         namedata.get().then((v) async {
  //           // print(v.data["user_name"]);
  //           await FirebaseFirestore.instance.collection("globalpics").add({
  //             "pic_name": picName,
  //             "pic_url": picUrl,
  //             "uid": uid,
  //             "Date": DateTime.now().toIso8601String().split("T")[0],
  //             "Time": DateTime.now().toIso8601String().split("T")[1],
  //             "user_name": v.data()!["user_name"],
  //             "comments": [],
  //             "ratings": {},
  //             "like": 0,
  //             "dislike": 0,
  //           });
  //         });

  //         return picUrl;
  //       });
  //     });
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  //   // return
  // }

  Future<void> sent_url_firestore(
      String picName, String uid, String link) async {
    try {
      for (var element in sendlist) {
        var picUrl =
            await storage.ref().child('pics/$uid/$picName').getDownloadURL();

        var namedata =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        var globalPicRef =
            await FirebaseFirestore.instance.collection("globalpics").add({
          "pic_name": picName,
          "pic_url": picUrl,
          "uid": uid,
          "Date": DateTime.now().toIso8601String().split("T")[0],
          "Time": DateTime.now().toIso8601String().split("T")[1],
          "user_name": namedata.data()!["user_name"],
          "comments": [],
          "ratings": {},
          "like": 0,
          "dislike": 0,
          "link": link
        });

        // Now that we have the globalPicRef, we can use its ID for sentpics and recivedpics
        await send2(picName, globalPicRef.id, link);
      }
    } catch (e) {
      print("Error in sent_url_firestore: $e");
    }
  }

  Future<void> send2(String picName, String globalPicId, String link) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user currently logged in");
      return;
    }

    for (var recipientId in sendlist) {
      try {
        // Check if already sent
        var alreadySentQuery = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("sentpics")
            .where("picdata", isEqualTo: globalPicId)
            .where("sentTo", isEqualTo: recipientId)
            .get();

        if (alreadySentQuery.docs.isEmpty) {
          // Add to recipient's recivedpics
          await FirebaseFirestore.instance
              .collection("users")
              .doc(recipientId)
              .collection("recivedpics")
              .add({
            "picdata": globalPicId,
            "userId": currentUser.uid,
            "sentTo": recipientId,
            "Date": DateTime.now().toIso8601String().split("T")[0],
            "Time": DateTime.now().toIso8601String().split("T")[1],
            "link": link,
          });

          // Add to sender's sentpics
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .collection("sentpics")
              .add({
            "picdata": globalPicId,
            "userId": currentUser.uid,
            "sentTo": recipientId,
            "Date": DateTime.now().toIso8601String().split("T")[0],
            "Time": DateTime.now().toIso8601String().split("T")[1],
            "link": link,
          });

          print("Picture sent to $recipientId");
        } else {
          print("Picture already sent to $recipientId");
        }
      } catch (e) {
        print("Error sending to $recipientId: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final argsid = args["id"];
    final argsname = args["picname"];
    final argspath = args["pathname"];
    final clothLink = args["link"];
    print(argsname);
    var i = FirebaseFirestore.instance.collection("users").doc(uid);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
      appBar: AppBar(
        title: const Text("RateFit"),
        backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
      ),
      body: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: SizedBox(
                child: Column(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                        future: i.get(),
                        builder: ((context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data!["friends"]["friends ids"].length ==
                              null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          print(snapshot.data!["friends"]);
                          if (argsid == "false") {
                            print("Smart boy");
                          } else {
                            print("nice boy");
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot
                                  .data!["friends"]["friends ids"].length,
                              itemBuilder: ((context, index) {
                                return SendProfile(
                                  sendersID: uid,
                                  list: sendlist,
                                  picID: argsid,
                                  profileID: snapshot.data!["friends"]
                                      ["friends ids"][index]["uid"],
                                  name: snapshot.data!["friends"]["friends ids"]
                                      [index]["name"],
                                  userName: snapshot.data!["friends"]
                                      ["friends ids"][index]["user_name"],
                                );
                              }));
                        })),
                  ],
                ),
              ),
            ),
            // sendlist.isEmpty
            //     ? const Text(" ")
            //     :
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: (() async {
                      if (argsname != null && argsid == "true") {
                        print("send pics true");
                        if (sendlist.isNotEmpty) {
                          setState(() {
                            sending = true;
                          });
                          await serverstorage
                              .upload(argsname, argspath, uid!)
                              .then((value) async {
                            Future.delayed(const Duration(seconds: 5),
                                () async {
                              sent_url_firestore(argsname, uid!, clothLink);
                              // .whenComplete(() => send2(argsname));
                              // send2(argsname);
                            });
                            Future.delayed(const Duration(seconds: 2), (() {
                              setState(() {
                                sen = true;
                              });
                            }));

                            Future.delayed(const Duration(seconds: 3), (() {
                              Navigator.of(context).pop();
                            }));
                          });
                        } else {
                          print("List is empty");
                          return;
                        }
                      } else {
                        // print("share pics true");
                        if (sendlist.isNotEmpty) {
                          setState(() {
                            sending = true;
                          });
                          // shared(argsid);
                          Future.delayed(const Duration(seconds: 2), (() {
                            setState(() {
                              sen = true;
                            });
                            Navigator.of(context).pop();
                          }));

                          print("done");
                        } else {
                          print("List is empty");
                          return;
                        }
                      }
                    }),
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ))
              ],
            )
          ],
        ),
        sending == false
            ? Container()
            : Sending(
                sent: sen,
              ),
      ]),
    );
  }
}

class Sending extends StatefulWidget {
  final bool? sent;
  const Sending({super.key, this.sent});

  @override
  State<Sending> createState() => _SendingState();
}

class _SendingState extends State<Sending> {
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
                mainAxisAlignment: widget.sent == false
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: widget.sent == false
                        ? const Text(
                            "Sending",
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            "Sent",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  widget.sent == false
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            value: widget.sent == false ? null : 0,
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
