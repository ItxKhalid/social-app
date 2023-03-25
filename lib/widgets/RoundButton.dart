import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  RoundButton(
      {Key? key,
      required this.btntxt,
       this.textColor = Colors.white,
       this.color = Colors.teal,
      required this.ontap,
      this.loading = false})
      : super(key: key);

  String btntxt;
  Function() ontap;
  final bool loading;
  Color? color, textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : ontap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(50)),
        child: Center(
            child: loading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    btntxt,
                    style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16,color: textColor),
                  )),
      ),
    );
  }
}
