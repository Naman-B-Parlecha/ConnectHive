import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onSelectImage});
  final void Function(File image) onSelectImage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedimage;
  void pickimage() async {
    final onpickedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (onpickedimage == null) {
      return;
    }
    setState(() {
      pickedimage = File(onpickedimage.path);
    });
    widget.onSelectImage(pickedimage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          foregroundColor: Colors.grey,
          foregroundImage: pickedimage != null ? FileImage(pickedimage!) : null,
        ),
        TextButton.icon(
            onPressed: pickimage,
            icon: Icon(Icons.image),
            label: Text('Add image'))
      ],
    );
  }
}
