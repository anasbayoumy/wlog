import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Single function that can pick from either source
Future<File?> pickImage({required ImageSource source}) async {
  try {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      return File(image.path);
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}

// Helper functions that use the main function
Future<File?> pickImageFromGallery() async {
  return pickImage(source: ImageSource.gallery);
}

Future<File?> pickImageFromCamera() async {
  return pickImage(source: ImageSource.camera);
}
