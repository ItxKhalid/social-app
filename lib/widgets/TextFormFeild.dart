import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget(
      {Key? key,
       this.myController,
       this.myFocusNode,
       this.onFieldSubmitted,
       this.formFieldValidator,
       this.keyboardType,
       this.hint,
       this.obscureText,
      this.enable = true,
      this.prefixIcon ,
      this.autoFocus = false})
      : super(key: key);

  final TextEditingController? myController;
  final FocusNode? myFocusNode;
  final Icon? prefixIcon;
  final FormFieldSetter? onFieldSubmitted;
  final FormFieldValidator? formFieldValidator;
  final TextInputType? keyboardType;
  final String? hint;
  final bool? obscureText;
  final bool? enable, autoFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      keyboardType: keyboardType,
      validator: formFieldValidator,
      obscureText: obscureText!,
      focusNode: myFocusNode,
      onFieldSubmitted: onFieldSubmitted,
      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 14,height: 0),
      decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(height: 0 ,color: AppColors.primaryTextTextColor.withOpacity(0.8)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(style: BorderStyle.solid)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(style: BorderStyle.solid,color: AppColors.iconBackgroundColor)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(style: BorderStyle.solid,color: AppColors.alertColor))
      ),
    );
  }
}
