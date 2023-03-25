import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/ViewModel/signup/signup_controller.dart';

import '../../res/color.dart';
import '../../utils/routes/route_name.dart';
import '../../widgets/RoundButton.dart';
import '../../widgets/TextFormFeild.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
    userNameFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          body: ChangeNotifierProvider(
            create: (_) => SignUpController(),
            child: Consumer<SignUpController>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: height * .03),
                        Text('WelCome to The App',
                            style: Theme.of(context).textTheme.headline3),
                        SizedBox(height: height * .01),
                        Text('Create your account to connected peoples',
                            style: Theme.of(context).textTheme.subtitle2),
                        SizedBox(height: height * .12),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormFieldWidget(
                                    myController: userNameController,
                                    myFocusNode: userNameFocus,
                                    onFieldSubmitted: (value) {},
                                    formFieldValidator: (value) {
                                      return value.isEmpty
                                          ? 'Enter Username'
                                          : null;
                                    },
                                    prefixIcon:
                                        const Icon(Icons.person_outline),
                                    keyboardType: TextInputType.emailAddress,
                                    hint: 'Username',
                                    enable: true,
                                    obscureText: false),
                                SizedBox(height: height * .03),
                                TextFormFieldWidget(
                                    myController: emailController,
                                    myFocusNode: emailFocus,
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    onFieldSubmitted: (value) {},
                                    formFieldValidator: (value) {
                                      return value.isEmpty
                                          ? 'EnterEmail'
                                          : null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    hint: 'Email',
                                    enable: true,
                                    obscureText: false),
                                SizedBox(height: height * .03),
                                TextFormFieldWidget(
                                    myController: passwordController,
                                    myFocusNode: passwordFocus,
                                    prefixIcon:
                                        const Icon(Icons.lock_outline_rounded),
                                    onFieldSubmitted: (value) {},
                                    formFieldValidator: (value) {
                                      return value.isEmpty
                                          ? 'Enter Password'
                                          : null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    hint: 'Password',
                                    enable: true,
                                    obscureText: true),
                              ],
                            )),
                        SizedBox(height: height * .03),
                        RoundButton(
                          btntxt: 'Sign Up',
                          loading: provider.loading,
                          ontap: () {
                            if (_formKey.currentState!.validate()) {
                              provider.signUp(
                                  context,
                                  userNameController.text.toString(),
                                  emailController.text.toString(),
                                  passwordController.text.toString());
                            }
                          },
                        ),
                        SizedBox(height: height * .04),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RouteName.loginView);
                          },
                          child: Text.rich(TextSpan(
                              text: 'Already have account ? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      fontSize: 15,
                                      color: AppColors.lightGrayColor),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline),
                                )
                              ])),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }
}
