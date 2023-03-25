import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:tech_media/ViewModel/services/session_manager.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/widgets/TextFormFeild.dart';

class ProfileController with ChangeNotifier {
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('user');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final nameController =TextEditingController();
  final phoneController =TextEditingController();
  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();

  final picker = ImagePicker();
  XFile? _image;

  XFile? get image => _image;

  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future pickGalleryImage(BuildContext context) async {
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedImage != null) {
      _image = XFile(pickedImage.path);
      notifyListeners();
      uploadImage(context);
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage != null) {
      _image = XFile(pickedImage.path);
      notifyListeners();
      uploadImage(context);
    }
  }

  void pickImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 120,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera),
                    title: const Text('Camera'),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text('Gallery'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void uploadImage(BuildContext context) async {
    setLoading(true);
    firebase_storage.Reference refStorage = firebase_storage
        .FirebaseStorage.instance
        .ref('/profileImage${SessionController().userId}');
    firebase_storage.UploadTask uploadTask =
        refStorage.putFile(File(image!.path).absolute);

    await Future.value(uploadTask);
    final newUrl = await refStorage.getDownloadURL();

    reference
        .child(SessionController().userId.toString())
        .update({'profile': newUrl.toString()}).then((value) {
      Utils().toastMassage('Profile Updated');
      setLoading(false);
      // _image = null;
    }).onError((error, stackTrace) {
      Utils().toastMassage(error.toString());
      setLoading(false);
    });
  }

  Future<void> showDialogEditProfile(BuildContext context, String name ,String phone) {
    nameController.text = name ;
    phoneController.text = phone;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Your Info'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormFieldWidget(
                    myController: nameController,
                    myFocusNode: nameFocus,
                    onFieldSubmitted: (newValue) {},
                    formFieldValidator: (value) {},
                    keyboardType: TextInputType.text,
                    hint: 'User Name',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  TextFormFieldWidget(
                    myController: phoneController,
                    myFocusNode: phoneFocus,
                    onFieldSubmitted: (newValue) {},
                    formFieldValidator: (value) {},
                    keyboardType: TextInputType.number,
                    hint: 'Phone Number',
                    obscureText: false,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              },
                  child:  const Text('Cancel',style: TextStyle(color: AppColors.alertColor),)
              ),
              TextButton(onPressed: (){
                reference.child(SessionController().userId.toString()).update({
                  'username' : nameController.text.toString(),
                  'phoneNumber' : phoneController.text.toString()
                }).then((value) {
                  nameController.clear();
                });
                Navigator.pop(context);
              },
                  child:  const Text('Update',style: TextStyle(color: AppColors.primaryTextTextColor),)
              ),
            ],
          );
        });
  }
}
