import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/ViewModel/login/login_controller.dart';

import '../../ViewModel/Methods.dart';
import '../../utils/utils.dart';
import '../../widgets/TextFormFeild.dart';
import '../dashboard/Home/HomeScreen.dart';
import '../dashboard/dashboard_screen.dart';
import '../signup/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(
                right: 35,
                left: 35,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 35,
                          top: MediaQuery.of(context).size.height * 0.1,
                          bottom: MediaQuery.of(context).size.height * 0.2),
                      child: const Text(
                        "Welcome\nBack",
                        style: TextStyle(color: Colors.white, fontSize: 33),
                      ),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormFieldWidget(
                                myController: _email,
                                myFocusNode: emailFocus,
                                onFieldSubmitted: (value) {},
                                prefixIcon: const Icon(Icons.email_outlined),
                                formFieldValidator: (value) {
                                  return value.isEmpty ? 'EnterEmail' : null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                hint: 'Email',
                                enable: true,
                                obscureText: false),
                            const SizedBox(height: 30),
                            TextFormFieldWidget(
                                myController: _password,
                                myFocusNode: passwordFocus,
                                onFieldSubmitted: (value) {},
                                prefixIcon: const Icon(Icons.person_outline),
                                formFieldValidator: (value) {
                                  return value.isEmpty
                                      ? 'Enter Password'
                                      : null;
                                },
                                keyboardType: TextInputType.text,
                                hint: 'Password',
                                enable: true,
                                obscureText: true),
                          ],
                        )),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        customButton(),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(() =>  SignUpView());
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                color: Color(0xff4c505b),
                              ),
                            ),
                          ),
                        ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget customButton() {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              Utils().toastMassage('LogIn Successfully',false);
              print("Login Sucessfull");
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const DashBoardScreen()));
            } else {
              Utils().toastMassage('LogIn Failed',true);
              print("Login Failed");
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
          Utils().toastMassage('Please fill form correctly',true);
          print("Please fill form correctly");
        }
      },
      child:  CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xff4c505b),
        child: isLoading  ? const CircularProgressIndicator() :const Icon(Icons.arrow_forward),
      ),
    );
  }
}
