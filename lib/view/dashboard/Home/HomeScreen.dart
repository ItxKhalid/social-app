import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../../ViewModel/Methods.dart';
import '../../../res/color.dart';
import '../../chat/ChatRoom.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  ///set RoomId for one to one chat
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  /// Search data in firestorm
  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("number", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.dividedColor,
      appBar: AppBar(
        backgroundColor: AppColors.dividedColor,
        title: const Text("Search for friends",
            style: TextStyle(color: Colors.white38)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.white38),
              onPressed: () => logOut(context))
        ],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      /// Form
                      Expanded(
                        child: TextField(
                          controller: _search,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search phone number",
                            hintStyle: const TextStyle(color: Colors.white38),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onSearch,
                        child: Container(
                          height: 62,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white38)),
                          child: const Center(
                              child: FaIcon(FontAwesomeIcons.search,
                                  color: Colors.white38)),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? Card(
                        elevation: 2,
                        color: Colors.white24,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName!,
                                userMap!['name']);
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap!,
                                ),
                                withNavBar: false);
                          },
                          leading: const CircleAvatar(
                              child: Icon(
                            Icons.person_rounded,
                            size: 40,
                          )
                          ),
                          title: Text(
                            userMap!['name'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(userMap!['number'],
                              style: const TextStyle(color: Colors.white38)),
                          trailing: const Icon(Icons.chat,color: Colors.white38),
                        ),
                      )
                    : Container(),
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.group),
      //   onPressed: () =>  PersistentNavBarNavigator.pushNewScreen(context, screen: const GroupChatHomeScreen(),withNavBar: false)
      //   //     Navigator.of(context).push(
      //   //   MaterialPageRoute(
      //   //     builder: (_) => const GroupChatHomeScreen(),
      //   //   ),
      //   // )
      // ),
    );
  }
}
