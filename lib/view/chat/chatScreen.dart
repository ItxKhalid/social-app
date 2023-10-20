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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            List<Widget> roomWidget = [];
            if(snapshot.hasData)
              {
                final chatRoom = snapshot.data!.docs.reversed.toList();
                for(var chatroom in chatRoom)
                  {
                    final roomList = Card(
                      elevation: 2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListTile(
                        title: Text(chatroom['name']),
                        subtitle: Text(chatroom['number']),
                      ),
                    );
                    roomWidget.add(roomList);
                  }
              }
            return Expanded(
              child: ListView(
                children: roomWidget,
              ),
            );
          },
        ),
      ),
      // Add any additional functionality or buttons here
    );
  }
}
