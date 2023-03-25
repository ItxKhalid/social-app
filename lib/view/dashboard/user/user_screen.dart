import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/ViewModel/services/session_manager.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/dashboard/massage/massage_screen.dart';

import '../../login/login_screen.dart';
import '../massage/massage2.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({Key? key}) : super(key: key);

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('user');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All User'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: LoginScreen(), withNavBar: false);
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: FirebaseAnimatedList(
          query: databaseReference,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            if (SessionController().userId.toString() ==
                snapshot.child('uid').value.toString()) {
              return Container();
            } else {
              return Card(
                child: ListTile(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: MessageGroupingWithTimeStamp(
                          name: snapshot.child('username').value.toString(),
                          email: snapshot.child('email').value.toString(),
                          image: snapshot.child('profile').value.toString(),
                        ),
                      withNavBar: false
                    );
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: AppColors.primaryTextTextColor)),
                    child: snapshot.child('profile').value.toString() == ''
                        ? Icon(Icons.person_outline)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(snapshot
                                    .child('profile')
                                    .value
                                    .toString())),
                          ),
                  ),
                  title: Text(snapshot.child('username').value.toString()),
                  subtitle: Text(snapshot.child('email').value.toString()),
                ),
              );
            }
          },
        ));
  }
}
