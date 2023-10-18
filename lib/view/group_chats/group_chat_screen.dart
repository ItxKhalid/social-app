import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'create_group/add_members.dart';
import 'group_chat_room.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
   /// full screen
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups", style: TextStyle(color: Colors.white38)),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : groupList.isEmpty
              ? const Center(
                  child: Text('No Groups',
                      style: TextStyle(color: Colors.white38, fontSize: 18)),
                )
              : ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListTile(
                        onTap: () {
                          Get.to(GroupChatRoom(
                            groupName: groupList[index]['name'],
                            groupChatId: groupList[index]['id'],
                          ));
                        },
                        leading: const CircleAvatar(child: Icon(Icons.group)),
                        title: Text(groupList[index]['name'],style: const TextStyle(color: Colors.white70)),
                      ),
                    );
                  },
                ),


      /// Add Group button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// for navigation
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: const AddMembersInGroup());
        },
        tooltip: "Create Group",
        child: const Icon(Icons.person_add_alt_rounded),
      ),
    );
  }
}
