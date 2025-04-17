import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFromGallery() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<File?> pickImageFromCamera() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      return File(image.path);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
