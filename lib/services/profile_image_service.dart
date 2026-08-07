import 'dart:convert';

import 'package:image_picker/image_picker.dart';

// Stores the photo as a data URL (like ImageStorageService for donations),
// so it works on both native platforms and Flutter Web — writing to the
// device filesystem via dart:io/path_provider does not work on web.
class ProfileImageService {
  ProfileImageService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickAndStoreImage(ImageSource source) async {
    final selectedImage = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (selectedImage == null) {
      return null;
    }

    final imageBytes = await selectedImage.readAsBytes();
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
