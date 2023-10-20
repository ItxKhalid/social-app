import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../utils/utils.dart';
import 'create_group.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "number": map['number'],
          "email": map['email'],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }
///
  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("number", isEqualTo: _search.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        // User found
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      } else {
        // User not found
        setState(() {
          userMap = null;
          isLoading = false;
        });
        Utils().toastMassage('User Not found', true);
      }
    });
  }


  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "number": userMap!['number'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members", style: TextStyle(color: Colors.white38)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    child: ListTile(
                      onTap: () => onRemoveMembers(index),
                      leading: const CircleAvatar(child: Icon(Icons.account_circle)),
                      title: Text(membersList[index]['name'], style: const TextStyle(color: Colors.white38)),
                      subtitle: Text(membersList[index]['number']??'', style: const TextStyle(color: Colors.white38)),
                      trailing: const Icon(Icons.close,color: Colors.white38),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            ///search TextField
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  keyboardType: const TextInputType.numberWithOptions(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "+92-----------24",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white)
                    )
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: const Text("Search"),
                  ),
            const SizedBox(height: 20),

            userMap != null
                ? Card(
              elevation: 2,
              color: Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListTile(
                      onTap: onResultTap,
                      leading: const CircleAvatar(child: Icon(Icons.account_circle)),
                      title: Text(userMap!['name'], style: const TextStyle(color: Colors.white38)),
                      subtitle: Text(userMap!['number'], style: const TextStyle(color: Colors.white38)),
                      trailing: const Icon(Icons.add,color: Colors.white38),
                    ),
                )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              child: const FaIcon(FontAwesomeIcons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
