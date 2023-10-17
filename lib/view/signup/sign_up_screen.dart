import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_media/view/login/login_screen.dart';

import '../../ViewModel/Methods.dart';
import '../../utils/utils.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
          child: Container(
            height: size.height / 20,
            width: size.height / 20,
            child: const CircularProgressIndicator(),
          ),
        )
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: size.width / 0.5,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios), onPressed: () {}),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                Container(
                  width: size.width / 1.1,
                  child: const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: size.width / 1.1,
                  child: const Text(
                    "Create Account to Contiue!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(size, "Name", Icons.person_2_rounded, _name),
                  ),
                ),
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: field(size, "email", Icons.alternate_email_outlined, _email),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(size, "password", Icons.lock_rounded, _password),
                  ),
                ),
                SizedBox(
                  height: size.height / 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xff4c505b),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      customButton(size),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Color(0xff4c505b),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          // _submit();
        }
        var userName = _name.text.trim();
        var userEmail = _email.text.trim();
        var userPassword = _password.text.trim();
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: userEmail, password: userPassword)
            .then((value) => {
          signUpUser(userName,userEmail, context),
        });
      },
      child: const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xff4c505b),
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget field(
      Size size, String hintText, IconData icon, TextEditingController cont) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors. black26),
            enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.teal)
            )
        ),
      ),
    );
  }
}


signUpUser(String userName, String userEmail,
    BuildContext context) async {
  User? userId = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance.collection("users").doc(userId?.uid).set({
      "name": userName,
      "email": userEmail,
      "status": "Unavalible",
      "uid": userId?.uid,

    }).then((value) {
      print("Success");
      // FirebaseAuth.instance.signOut();
      print(userId!.uid);
      Utils().toastMassage('User Created Successfully', true);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
    });
  } catch (e) {
    print("Error $e");
  }
}