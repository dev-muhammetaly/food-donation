import 'dart:convert';

import 'package:image_picker/image_picker.dart';

//The image is converted into a data URL so it works on both: Android devices and Web browsers

class ImageStorageService {
  //Creates the image service.
  ImageStorageService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

// Stores the ImagePicker object used to open the camera or device gallery.

  final ImagePicker _imagePicker;

//Opens the selected image source and converts the image
  Future<String?> pickAndStoreImage(ImageSource source) async {
    final selectedImage = await _imagePicker.pickImage(
      source: source,
      maxWidth: 900,
      imageQuality: 55,
    );

    if (selectedImage == null) {
      return null;
    }


    final imageBytes = await selectedImage.readAsBytes();

    // SharedPreferences has limited browser storage, so image must be smaller  
    if (imageBytes.lengthInBytes > 1024 * 1024) {
      throw Exception(
        'The selected image is too large. Please choose an image smaller than 1 MB.',
      );
    }

//Determines the image format
    final mimeType = _mimeTypeFor(selectedImage.name);
    return 'data:$mimeType;base64,${base64Encode(imageBytes)}';
  }

  String _mimeTypeFor(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
