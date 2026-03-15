import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/classifier_service.dart';
import '../../../services/auth_service.dart';

class UploadBinScreen extends StatefulWidget {
  const UploadBinScreen({super.key});

  @override
  State<UploadBinScreen> createState() => _UploadBinScreenState();
}

class _UploadBinScreenState extends State<UploadBinScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  final AuthService _authService = AuthService();

  String? selectedBinId;
  List<String> binIds = [];
  bool _isLoadingBins = true;

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) setState(() => _isLoadingBins = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        if (mounted) setState(() => _isLoadingBins = false);
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? userApartmentId = userData['apartmentId']?.toString().trim();

      if (userApartmentId == null || userApartmentId.isEmpty) {
        if (mounted) setState(() => _isLoadingBins = false);
        return;
      }

      var snapshot = await FirebaseFirestore.instance
          .collection('bins')
          .where('blockID', isEqualTo: userApartmentId)
          .get();

      if (mounted) {
        setState(() {
          binIds = snapshot.docs.map((doc) => doc.id).toList();
          if (binIds.isNotEmpty) {
            selectedBinId = binIds.first;
          }
          _isLoadingBins = false;
        });
      }
    } catch (e) {
      print("Error fetching bins: $e");
      if (mounted) {
        setState(() => _isLoadingBins = false);
      }
    }
  }

  int _getLevelCode(String status) {
    String s = status.toLowerCase();

    if (s.contains("half")) {
      return 1;
    } else if (s.contains("full")) {
      return 2;
    } else {
      return 0;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _handleUsePhoto() async {
    if (selectedBinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bin first!")),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take a photo first!")),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final String? result = await ClassifierService.predictLevel(_image!.path);

      if (result != null) {
        final String uid = FirebaseAuth.instance.currentUser!.uid;

        await _authService.updateBinStatus(uid: uid, status: result);

        int levelCode = _getLevelCode(result);
        await FirebaseFirestore.instance
            .collection('bins')
            .doc(selectedBinId)
            .update({'status': result, 'levelCode': levelCode});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('disposal_history')
            .add({
              'binId': selectedBinId,
              'status': result,
              'timestamp': FieldValue.serverTimestamp(),
              'isCollected': result.toLowerCase().contains("empty"),
            });

        if (!mounted) return;
        _showResultDialog(result);
      } else {
        throw Exception("Analysis failed to detect a level.");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showResultDialog(String level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Analysis Complete"),
        content: Text("Bin ($selectedBinId) is detected as: $level"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Upload Bin Photo",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Dropdown Section එක
            if (_isLoadingBins)
              const CircularProgressIndicator(color: brandGreen)
            else if (binIds.isEmpty)
              const Text(
                "No bins found in your block.",
                style: TextStyle(color: Colors.red),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBinId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: binIds.map((String id) {
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          "Disposal Bin: $id",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBinId = newValue;
                      });
                    },
                  ),
                ),
              ),

            const SizedBox(height: 30),

            const Text(
              "Capture a clear photo\nof your Bin",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
                image: _image != null
                    ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _image == null
                  ? const Center(
                      child: Icon(Icons.camera_alt_outlined, size: 80),
                    )
                  : null,
            ),

            const SizedBox(height: 40),

            _buildIconBtn(
              label: "Take photo",
              icon: Icons.camera_alt_outlined,
              bgColor: lightGreyBtn,
              textColor: Colors.black,
              onTap: () => _pickImage(ImageSource.camera),
            ),

            const SizedBox(height: 16),

            _buildIconBtn(
              label: "Choose from gallery",
              icon: Icons.photo_library_outlined,
              bgColor: lightGreyBtn,
              textColor: Colors.black,
              onTap: () => _pickImage(ImageSource.gallery),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _handleUsePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}