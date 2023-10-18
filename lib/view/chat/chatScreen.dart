import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatRoomHomeScreen extends StatefulWidget {
  const UserChatRoomHomeScreen({Key? key}) : super(key: key);

  @override
  _UserChatRoomHomeScreenState createState() => _UserChatRoomHomeScreenState();
}

class _UserChatRoomHomeScreenState extends State<UserChatRoomHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List chatRoomList = [];

  @override
  void initState() {
    super.initState();
    getChatRooms();
  }

  void getChatRooms() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('chatroom')
        .where('users', arrayContains: uid)
        .get()
        .then((value) {
      setState(() {
        chatRoomList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey, // Change to your desired color
      appBar: AppBar(
        backgroundColor: Colors.grey, // Change to your desired color
        title: const Text("Chat Rooms", style: TextStyle(color: Colors.white38)),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: chatRoomList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white24, // Change to your desired color
                ),
                child: ListTile(
                  onTap: () {
                    // Handle chat room selection, navigate to chat screen, etc.
                  },
                  leading: CircleAvatar(
                    child: Icon(Icons.person, size: 40), // Change as needed
                  ),
                  title: Text(
                    chatRoomList[index]['name'], // Change to chat room name
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // Add any additional functionality or buttons here
    );
  }
}
