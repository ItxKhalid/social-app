import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/ViewModel/services/session_manager.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/utils.dart';

class MassageScreen extends StatefulWidget {
  MassageScreen(
      {Key? key,
      required this.name,
      required this.email,
      this.receiverId,
      required this.image})
      : super(key: key);

  String name, image, email;
  String? receiverId;

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  final massageController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Chat');

  @override
  Widget build(BuildContext context) {
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
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return Text(index.toString());
                    })),
            Padding(
              padding: const EdgeInsets.only(bottom: 10,right: 24 ,left: 24),
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
      Utils().toastMassage('Enter massage');
    } else {
      final timeStamp = DateTime.now().microsecondsSinceEpoch.toString();
      ref.child(timeStamp).set({
        'isSeen': false,
        'massage': massageController.text.toString(),
        'sender': SessionController().userId.toString(),
        'receiver': widget.receiverId,
        'type': 'text',
        'time': timeStamp.toString()
      }).then((value) {
        massageController.clear();
      });
    }
  }
}
