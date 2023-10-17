
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils{


  static void feildFocus(BuildContext context ,FocusNode currentFocus ,FocusNode nextFocus){
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void toastMassage(String massage,bool onError){
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: onError==false ? Colors.tealAccent : const Color(0xffEA9890),
        textColor: onError==false ? Colors.black : Colors.white,
        fontSize: 16.0
    );
  }
}