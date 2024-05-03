import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerwidget extends StatefulWidget {
  final Function(String imageUrl) onfileChanged;
  const ImagePickerwidget({super.key, required this.onfileChanged});

  @override
  State<ImagePickerwidget> createState() => _ImagePickerwidgetState();
}

class _ImagePickerwidgetState extends State<ImagePickerwidget> {
  final ImagePicker imagePicker = ImagePicker();
  String? imgUrl;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
