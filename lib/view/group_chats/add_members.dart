import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_media/utils/utils.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
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

  void onAddMembers() async {
    membersList.add(userMap);

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId}).then((value) {
          Navigator.pop(context);
          Utils().toastMassage('Member Added successfully', false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members",style: TextStyle(
          color: Colors.white70,
          fontSize: size.width / 18,
          fontWeight: FontWeight.w500,
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: size.height / 20,
              ),
              TextField(
                controller: _search,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search for friends",
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
              userMap != null
                  ? Card(
                elevation: 2,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 20),
                    child: ListTile(
                        onTap: onAddMembers,
                        leading: const CircleAvatar(child: FaIcon(FontAwesomeIcons.person)),
                        title: Text(userMap!['name'],style: TextStyle(
                          color: Colors.white70,
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                        )),
                        subtitle: Text(userMap!['number'],style: TextStyle(
                          color: Colors.white38,
                          fontSize: size.width / 28,
                          fontWeight: FontWeight.w500,
                        )),
                        trailing: const FaIcon(FontAwesomeIcons.add,color: Colors.white38),
                      ),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
