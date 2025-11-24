import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_food_regional/core/services/image_upload_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageUploaded;
  final String label;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    this.label = 'Upload Image',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploading = true;
        });

        try {
          final url = await _uploadService.uploadImage(_imageFile!);
          setState(() {
            _uploadedImageUrl = url;
            _isUploading = false;
          });
          widget.onImageUploaded(url);
        } catch (e) {
          setState(() {
            _isUploading = false;
            _imageFile = null; // Revert if upload fails
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _showPickerOptions,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _uploadedImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, size: 50)),
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to upload', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
          ),
        ),
      ],
    );
  }
}
