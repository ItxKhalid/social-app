import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../res/color.dart';
import '../chat/ChatRoom.dart';
import '../dashboard/massage/massage2.dart';
import 'group_info.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

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
        .collection('groups')
        .doc(groupChatId)
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
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  final ScrollController _scrollController = ScrollController();
  bool scrollbool = false;
  double itemHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(groupName, style: const TextStyle(color: Colors.white38)),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupInfo(
                          groupName: groupName,
                          groupId: groupChatId,
                        ),
                      ),
                    ),
                icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(groupChatId)
                      .collection('chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
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
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);
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

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
                left: chatMap['sendBy'] == _auth.currentUser!.displayName
                    ? 100
                    : 8.0,
                right: chatMap['sendBy'] == _auth.currentUser!.displayName
                    ? 8
                    : 100,
                top: 10,
                bottom: 10),
            child: CustomPaint(
              // size: const Size.fromWidth(50),
              painter: MessageBubble(
                  color: chatMap['sendBy'] == _auth.currentUser!.displayName
                      ? const Color(0xffDAF0F3)
                      : const Color(0xffC795B2),
                  alignment: chatMap['sendBy'] != _auth.currentUser!.displayName
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  tail: true),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(left: chatMap['sendBy'] != _auth.currentUser!.displayName ? 15 :6, right: 20),
                      child: Text(
                        chatMap['sendBy'].toString(),
                        style: TextStyle(
                            fontSize: 11,
                            color: chatMap['sendBy'] !=
                                    _auth.currentUser!.displayName
                                ? Colors.white70
                                : Colors.teal),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left:
                            chatMap['sendby'] == _auth.currentUser!.displayName
                                ? 20
                                : 20,
                        right:
                            chatMap['sendby'] == _auth.currentUser!.displayName
                                ? 15
                                : 20,
                      ),
                      child: Text(
                        chatMap['message'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: chatMap['sendBy'] !=
                                    _auth.currentUser!.displayName
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Column(
          crossAxisAlignment: chatMap['sendby'] != _auth.currentUser!.displayName ? CrossAxisAlignment.start :CrossAxisAlignment.end,
          children: [
            Padding(
              padding:  EdgeInsets.only(top: 10,left: chatMap['sendBy'] != _auth.currentUser!.displayName ? 15 :6, right: 20),
              child: Text(
                '${chatMap['sendby'].toString()}',
                style: TextStyle(
                    fontSize: 16,
                    color: chatMap['sendBy'] !=
                        _auth.currentUser!.displayName
                        ? Colors.white70
                        : Colors.teal),
              ),
            ),
            Container(
              height: size.height / 2.5,
              width: size.width,
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left:
                    chatMap['sendby'] == _auth.currentUser!.displayName ? 150 : 10,
                right:
                    chatMap['sendby'] == _auth.currentUser!.displayName ? 10 : 150,
              ),
              child: InkWell(
                onTap: () => Get.to(
                  ShowImage(
                    imageUrl: chatMap['message'],
                  ),
                ),
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(15)),
                  // alignment: chatMap['message'] != "" ? null : Alignment.center,
                  child: chatMap['message'] != ""
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          chatMap['message'],
                          fit: BoxFit.cover,
                        ),
                      )
                      : Center(child: const CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
