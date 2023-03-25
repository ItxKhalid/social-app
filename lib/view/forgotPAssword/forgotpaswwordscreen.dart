import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/ViewModel/forgot_password/forgot_password_controller.dart';
import 'package:tech_media/ViewModel/login/login_controller.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/widgets/RoundButton.dart';
import 'package:tech_media/widgets/TextFormFeild.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    emailFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * .03),
                Text('Forgot Password',
                    style: Theme.of(context).textTheme.headline3),
                SizedBox(height: height * .01),
                Text('Enter the register Email you want\n   to send the reset link',
                    style: Theme.of(context).textTheme.subtitle2),
                SizedBox(height: height * .2),
                Form(
                    key: _formKey,
                    child: TextFormFieldWidget(
                        myController: emailController,
                        myFocusNode: emailFocus,
                        onFieldSubmitted: (value) {},
                        prefixIcon: const Icon(Icons.email_outlined),
                        formFieldValidator: (value) {
                          return value.isEmpty ? 'EnterEmail' : null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        hint: 'Email',
                        enable: true,
                        obscureText: false)),

                SizedBox(height: height * .03),
                ChangeNotifierProvider(
                  create: (_) => ForgotPasswordController(),
                  child: Consumer<ForgotPasswordController>(
                    builder: (context, provider, child) {
                      return RoundButton(
                        btntxt: 'Send Email',
                        loading: provider.loading,
                        ontap: () {
                          if (_formKey.currentState!.validate()) {
                            provider.forgotPassword(
                                context,
                                emailController.text
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
