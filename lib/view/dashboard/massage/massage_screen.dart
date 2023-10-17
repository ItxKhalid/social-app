import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/ViewModel/services/session_manager.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/utils.dart';

import 'massage2.dart';

class MassageScreen extends StatefulWidget {
  MassageScreen({
    Key? key,
    required this.name,
    required this.email,
    this.receiverId,
    required this.image,
  }) : super(key: key);

  final String name, image, email;
  final String? receiverId;

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  final massageController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.reference().child('Chat');

  // Create a list to store the messages
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // Set up a listener to retrieve messages in real-time
    ref.onChildAdded.listen((event) {
      final message = event.snapshot.value as Map;
      final sender = message['sender'];
      final receiver = message['receiver'];

      // Check if the message is for the current user
      if (sender == SessionController().userId.toString() &&
          receiver == widget.receiverId) {
        setState(() {
          // Add the message to the list
          messages.add(message['massage']);
        });
      }
    });
  }
  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;
    SessionController().userId = user!.uid.toString();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.name.toString()),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: false,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(), // ← can't
                itemCount: messages.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment:   SessionController().userId == user.uid ?CrossAxisAlignment.end :CrossAxisAlignment.start ,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CustomPaint(
                            painter: MessageBubble(
                                color:   SessionController().userId == user.uid ? Color(0xffDAF0F3) : Color(0xffC795B2),
                                alignment:  SessionController().userId == user.uid ? Alignment.topRight : Alignment.topLeft,
                                tail: true
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * .7,
                              ),
                              margin: const EdgeInsets.fromLTRB(17, 7, 7, 7),

                              child: Padding(
                                padding:const EdgeInsets.only(left: 0, right: 10 ,bottom: 10),
                                child: Text(
                                  messages[index].toString()  ,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 15 ,
                                      color:  const Color(0xff677D81)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 24, left: 24),
              child: TextFormField(
                controller: massageController,
                maxLines: 4,
                cursorColor: AppColors.primaryTextTextColor,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 19, height: 0),
                decoration: InputDecoration(
                  hintText: 'Enter Massage',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      sendMassage();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: CircleAvatar(
                        maxRadius: 23,
                        backgroundColor: AppColors.primaryTextTextColor,
                        child: Icon(Icons.send, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                      height: 0,
                      color: AppColors.primaryTextTextColor.withOpacity(0.8)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(style: BorderStyle.solid)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                          style: BorderStyle.solid,
                          color: AppColors.inputTextBorderColor)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendMassage() {
    if (massageController.text.isEmpty) {
      Utils().toastMassage('Enter message',false);
    } else {
      final timeStamp = DateTime.now().microsecondsSinceEpoch.toString();
      ref.child(timeStamp).set({
        'isSeen': false,
        'massage': massageController.text.toString(),
        'sender': SessionController().userId.toString(),
        'receiver': widget.receiverId,
        'type': 'text',
        'time': timeStamp.toString(),
      }).then((value) {
        massageController.clear();
      });
    }
  }
}
