import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendProfile extends StatefulWidget {
  final String? sendersID;
  final String? name;
  final List? list;
  final String? picID;
  final String? profileID;
  final String? userName;
  const SendProfile(
      {this.sendersID,
      this.userName,
      this.profileID,
      this.picID,
      this.name,
      this.list,
      super.key});

  @override
  State<SendProfile> createState() => _SendProfileState();
}

class _SendProfileState extends State<SendProfile> {
  bool tick = false;

  List tempadd = [];
  List tempremove = [];

  // Map<String, String> data = {
  //   "sendtoUserUid": widget.profileID,
  //   "picDataId": widget.picID,
  //   "senderUid": widget.sendersID
  // };

  check() {
    if (widget.list!.isEmpty) {
      widget.list!.add(widget.profileID);
    } else if (widget.list!.isNotEmpty) {
      for (var i in widget.list!) {
        if (widget.profileID != i) {
          tempadd.add(widget.profileID);
        } else if (widget.list!.contains(widget.profileID)) {
          tempremove.add(widget.profileID);
        }
      }
      if (tempadd.isNotEmpty) {
        widget.list!.add(tempadd[0]);
      }
      widget.list!.removeWhere((element) => tempremove.contains(element));
      tempremove.clear();
      tempadd.clear();
      // print(tempremove);
      // print(tempadd);
    }
  }

  void sendchat(sendtoUserUid, picDataId, senderUid) {
    var i = FirebaseFirestore.instance
        .collection("users/8x907mNurAgZ2xvma1DG/user_data")
        .doc(sendtoUserUid);
    i.get().then((value) => {
          i.update({
            "chart": FieldValue.arrayUnion([
              {
                "picdata": "$picDataId",
                "userId": "$senderUid",
              }
            ]),
          })
        });
  }

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.cyan,
    Colors.grey,
    Colors.lightBlue,
    Colors.yellow,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.blueGrey,
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.cyan,
    Colors.grey,
    Colors.lightBlue,
    Colors.yellow,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.blueGrey,
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.cyan,
    Colors.grey,
    Colors.lightBlue,
    Colors.yellow,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // print(widget.picID);
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          SizedBox(
            height: size.height / 10,
            width: size.width,
            child: ListTile(
              onTap: () {
                setState(() {
                  tick = !tick;
                });
                check();
                print(widget.list);
              },
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0),
                    child: Container(
                      height: size.height / 18,
                      width: size.width / 9,
                      decoration: BoxDecoration(
                          color: colors[widget.userName!.split('').length],
                          borderRadius:
                              BorderRadius.circular(size.height / 10)),
                      child: Center(
                          child: Text(
                              widget.userName!.toUpperCase().split('')[0],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18))),
                    ),
                  ),
                ],
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: widget.userName == null
                              ? const Text(" ")
                              : Text(
                                  widget.userName!,
                                  style: TextStyle(
                                      fontSize: size.height / 50,
                                      color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: widget.name == null
                              ? const Text(" ")
                              : Text(
                                  widget.name!,
                                  style: TextStyle(
                                    fontSize: size.height / 60,
                                    color: const Color.fromARGB(
                                        119, 255, 255, 255),
                                  ),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: size.height / 38,
                      width: size.width / 19,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.height / 10)),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: tick == true
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.lightBlue,
                              )
                            : null,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
