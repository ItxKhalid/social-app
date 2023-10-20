import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../res/color.dart';
import '../dashboard/massage/massage2.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      Utils().toastMassage('Enter some text', false);
      print("Enter Some Text");
    }
  }

  final ScrollController _scrollController = ScrollController();
  bool scrollbool = false;
  double itemHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: AppColors.dividedColor,
          title: StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection("users").doc(userMap['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Column(
                    children: [
                      Text(userMap['name'],
                          style: const TextStyle(color: Colors.white)),
                      Text(
                        snapshot.data!['status'],
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white38),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 1.25,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      if (_scrollController.hasClients) {
                        double maxScrollExtent =
                            _scrollController.position.maxScrollExtent;
                        double offset = _scrollController.offset;
                        double reversedOffset = maxScrollExtent - offset;
                        int bottomItemIndex =
                            (reversedOffset / itemHeight).ceil();

                        // print("----------------------current index          ${bottomItemIndex}--------------------------");
                        if (bottomItemIndex > 2) {
                          scrollbool = false;
                        } else {
                          scrollbool = true;
                        }
                      }

                      if (snapshot.data!.docs.length > 3 &&
                          scrollbool == true) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          }
                        });
                        scrollbool = false;
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        reverse: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.dividedColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextFormField(
                            controller: _message,
                            maxLines: 3,
                            style: const TextStyle(
                                color: AppColors.lightGrayColor),
                            decoration: InputDecoration(
                                fillColor: AppColors.dividedColor,
                                suffixIcon: IconButton(
                                  onPressed: () => getImage(),
                                  icon: const Icon(Icons.photo,
                                      color: AppColors.lightGrayColor),
                                ),
                                hintText: "Send Message",
                                hintStyle: const TextStyle(
                                    color: AppColors.lightGrayColor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        style: BorderStyle.solid,
                                        color: AppColors.iconBackgroundColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        style: BorderStyle.solid,
                                        color: AppColors.lightGrayColor)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 63,
                        width: 60,
                        decoration: BoxDecoration(
                            color: AppColors.dividedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white70)),
                        child: IconButton(
                            icon: const Icon(Icons.send,
                                color: AppColors.lightGrayColor),
                            onPressed: onSendMessage),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDeleteMessageDialog(context, _firestore
            .collection('chatroom')
            .doc(chatRoomId)
            .collection('chats')
            .doc(map['id']));
      },
          child: map['type'] == "text"
              ? Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: map['sendby'] == _auth.currentUser!.displayName
                      ? 100
                      : 8.0,
                  right: map['sendby'] == _auth.currentUser!.displayName
                      ? 8
                      : 100,
                  top: 10,
                  bottom: 10),
              child: CustomPaint(
                // size: const Size.fromWidth(50),
                painter: MessageBubble(
                    color: map['sendby'] == _auth.currentUser!.displayName
                        ? Color(0xffDAF0F3)
                        : Color(0xffC795B2),
                    alignment: map['sendby'] == _auth.currentUser!.displayName
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    tail: true),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: map['sendby'] == _auth.currentUser!.displayName
                          ? 15
                          : 20,
                      right: map['sendby'] == _auth.currentUser!.displayName
                          ? 20:15,
                      top: 10,
                      bottom: 10),
                  child: Text(
                    map['message'].toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 15,
                        color: map['sendby'] != _auth.currentUser!.displayName
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ),
          )
              : Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              height: size.height / 2.5,
              width: size.width,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              alignment: map['sendby'] == _auth.currentUser!.displayName
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () => Get.to(
                  ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(15)),
                  alignment: map['message'] != "" ? null : Alignment.center,
                  child: map['message'] != ""
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      map['message'],
                      fit: BoxFit.cover,
                    ),
                  )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
        // : Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
        //     child: Container(
        //       height: size.height / 2.5,
        //       width: size.width,
        //       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        //       alignment: map['sendby'] == _auth.currentUser!.displayName
        //           ? Alignment.centerRight
        //           : Alignment.centerLeft,
        //       child: InkWell(
        //         onTap: () => Navigator.of(context).push(
        //           MaterialPageRoute(
        //             builder: (_) => ShowImage(
        //               imageUrl: map['message'],
        //             ),
        //           ),
        //         ),
        //         child: Container(
        //           height: size.height / 2.5,
        //           width: size.width / 2,
        //           decoration: BoxDecoration(
        //               border: Border.all(color: Colors.black45),
        //               borderRadius: BorderRadius.circular(15)),
        //           alignment: map['message'] != "" ? null : Alignment.center,
        //           child: map['message'] != ""
        //               ? ClipRRect(
        //                   borderRadius: BorderRadius.circular(15),
        //                   child: Image.network(
        //                     map['message'],
        //                     fit: BoxFit.cover,
        //                   ),
        //                 )
        //               : const CircularProgressIndicator(),
        //         ),
        //       ),
        //     ),
        //   );
  }
  // Function to show the delete message dialog.
  // Updated showDeleteMessageDialog function
  Future<void> showDeleteMessageDialog(BuildContext context, DocumentReference messageRef) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Message"),
            content: const Text("Are you sure you want to delete this message?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () async {
                  // Use the provided messageRef to delete the document
                  await messageRef.delete().then((value) => Navigator.of(context).pop());
                },
              ),
            ],
          );
        }
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl, fit: BoxFit.fill),
      ),
    );
  }
}

//
