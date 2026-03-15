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
  String selectedWasteType = 'Organic';
  List<String> binIds = [];
  bool _isLoadingBins = true;
  final List<String> wasteTypes = ['Organic', 'Plastic', 'Glass'];

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
      debugPrint("Error fetching bins: $e");
      if (mounted) setState(() => _isLoadingBins = false);
    }
  }

  int _getLevelCode(String status) {
    String s = status.toLowerCase();
    if (s.contains("half")) return 1;
    if (s.contains("full")) return 2;
    return 0;
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
    if (selectedBinId == null || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a bin and capture a photo!"),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final String? result = await ClassifierService.predictLevel(_image!.path);

      if (result != null) {
        final String uid = FirebaseAuth.instance.currentUser!.uid;
        int levelCode = _getLevelCode(result);

        await _authService.updateBinStatus(uid: uid, status: result);

        await FirebaseFirestore.instance
            .collection('bins')
            .doc(selectedBinId)
            .update({
              'status': result,
              'levelCode': levelCode,
              'lastWasteType': selectedWasteType,
            });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('disposal_history')
            .add({
              'binId': selectedBinId,
              'status': result,
              'wasteType': selectedWasteType,
              'timestamp': FieldValue.serverTimestamp(),
              'isCollected': result.toLowerCase().contains("empty"),
            });

        if (!mounted) return;

        _showSuccessDialog(result);
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

  void _showSuccessDialog(String level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Analysis Complete"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bin ID: $selectedBinId"),
            Text("Waste Type: $selectedWasteType"),
            const Divider(),
            const Text(
              "Detected Level:",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              level.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1B5E36),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              "DONE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);
    const Color lightGrey = Color(0xFFF5F5F5);

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
          "Dispose Waste",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildLabel("Select Your Bin"),
            if (_isLoadingBins)
              const LinearProgressIndicator(color: brandGreen)
            else
              _buildDropdownContainer(
                child: DropdownButton<String>(
                  value: selectedBinId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: brandGreen,
                  ),
                  items: binIds
                      .map(
                        (id) => DropdownMenuItem(
                          value: id,
                          child: Text("Bin: $id"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedBinId = val),
                ),
              ),

            const SizedBox(height: 16),

            _buildLabel("Waste Category"),
            _buildDropdownContainer(
              child: DropdownButton<String>(
                value: selectedWasteType,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.recycling, color: brandGreen),
                items: wasteTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedWasteType = val!),
              ),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 60,
                            color: brandGreen,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tap to capture bin level",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    label: "Gallery",
                    icon: Icons.photo_library_outlined,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionBtn(
                    label: "Retake",
                    icon: Icons.refresh_rounded,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _handleUsePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Analyze & Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: Colors.black87),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
