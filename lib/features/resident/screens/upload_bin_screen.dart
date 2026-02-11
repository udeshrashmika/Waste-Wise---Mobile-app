import 'dart:io'; // Needed to work with files
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the plugin

class UploadBinScreen extends StatefulWidget {
  const UploadBinScreen({super.key});

  @override
  State<UploadBinScreen> createState() => _UploadBinScreenState();
}

class _UploadBinScreenState extends State<UploadBinScreen> {
  // Variable to store the selected image
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to open Camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color brandGreen = Color(0xFF1B5E36);
    const Color lightGreyBtn = Color(0xFFF3F3F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Capture a clear photo\nof your Bin",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 30),

            // 2. Photo Placeholder (Dynamic)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
                // If image exists, show it. Otherwise show grey box.
                image: _image != null
                    ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _image == null
                  ? const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 80,
                        color: Colors.black87,
                      ),
                    )
                  : null, // Hide icon if image is there
            ),

            const SizedBox(height: 40),

            // 3. Action Buttons

            // "Take photo" Button (NOW WORKS!)
            _buildIconBtn(
              label: "Take photo",
              icon: Icons.camera_alt_outlined,
              bgColor: lightGreyBtn,
              textColor: Colors.black,
              onTap: () {
                _pickImage(ImageSource.camera); // <--- Opens Camera
              },
            ),

            const SizedBox(height: 16),

            // "Choose from gallery" Button (NOW WORKS!)
            _buildIconBtn(
              label: "Choose from gallery",
              icon: Icons.photo_library_outlined,
              bgColor: lightGreyBtn,
              textColor: Colors.black,
              onTap: () {
                _pickImage(ImageSource.gallery); // <--- Opens Gallery
              },
            ),

            const SizedBox(height: 16),

            // "Use Photo" Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_image != null) {
                    // TODO: Send image to TensorFlow Lite here
                    print("Photo selected: ${_image!.path}");
                    Navigator.pop(context); // Go back after selecting
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please take a photo first!"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Use Photo",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Buttons
  Widget _buildIconBtn({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
