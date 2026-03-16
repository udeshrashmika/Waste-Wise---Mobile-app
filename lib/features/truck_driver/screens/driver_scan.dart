import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class DriverScanScreen extends StatefulWidget {
  const DriverScanScreen({super.key});

  @override
  State<DriverScanScreen> createState() => _DriverScanScreenState();
}

class _DriverScanScreenState extends State<DriverScanScreen> {
  
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, 
    detectionTimeoutMs: 2000, 
    facing: CameraFacing.back, 
    formats: const [BarcodeFormat.qrCode], 
    returnImage: false,
  );

  bool _isProcessing = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Final Disposal", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Scan Disposal Site QR Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Place the QR code inside the frame to Scan.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (capture) async {
                        if (_isProcessing) return; 

                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;

                        
                        String scannedBinId = barcodes.first.rawValue?.trim() ?? "";
                        if (scannedBinId.isEmpty) return;

                        setState(() { _isProcessing = true; });

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null || user.email == null) throw Exception("User not logged in");

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Validating Bin... Please wait ⏳")),
                            );
                          }

                          
                          var binDoc = await FirebaseFirestore.instance.collection('bins').doc(scannedBinId).get();
                          
                          if (!binDoc.exists) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid QR Code! Bin not found in database."), backgroundColor: Colors.red));
                            }
                            return;
                          }

                          
                          String actualLocationName = binDoc.data()?['locationName'] ?? "";

                          
                          var scheduleQuery = await FirebaseFirestore.instance
                              .collection('schedules')
                              .where('driverId', isEqualTo: user.email)
                              .get();

                          var activeSchedules = scheduleQuery.docs.where((doc) {
                            var status = (doc.data())['status'];
                            return status != 'Completed';
                          }).toList();

                          if (activeSchedules.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No active tasks found!")));
                            }
                            return;
                          }

                          activeSchedules.sort((a, b) {
                            var aTime = (a.data())['createdAt'] as Timestamp?;
                            var bTime = (b.data())['createdAt'] as Timestamp?;
                            if (aTime == null || bTime == null) return 0;
                            return aTime.compareTo(bTime);
                          });

                          var currentTaskDoc = activeSchedules.first;
                          String expectedRoute = currentTaskDoc.data()['route'] ?? "";

                          
                          if (actualLocationName != expectedRoute) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Wrong Bin! ❌ You scanned $actualLocationName, but you should scan $expectedRoute"),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                            return; 
                          }

                         
                          await binDoc.reference.update({
                            'status': 'Empty', 
                            'fill_level': 0, 
                            'levelCode': 0, 
                            'last_collected': FieldValue.serverTimestamp(),
                          });

                          await FirebaseFirestore.instance
                              .collection('schedules')
                              .doc(currentTaskDoc.id)
                              .update({'status': 'Completed'}); 

                          String blockID = "Unknown Block";
                          if (actualLocationName.contains('-')) {
                            blockID = actualLocationName.split('-').first.trim(); 
                          }

                          await FirebaseFirestore.instance.collection('notifications').add({
                            'blockID': blockID,
                            'type': 'collection',
                            'title': 'Disposal Completed ✅',
                            'message': 'Waste for $blockID has been successfully collected by the driver.',
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Success! Trip Completed ✅"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }

                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error processing scan: $error"), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          
                          await Future.delayed(const Duration(seconds: 3));
                          if (mounted) {
                            setState(() { _isProcessing = false; });
                          }
                        }
                      },
                    ),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: 250,
                      height: 250,
                    ),
                    
                    const Positioned(top: 60, left: 40, child: CornerBracket(isTop: true, isLeft: true)),
                    const Positioned(top: 60, right: 40, child: CornerBracket(isTop: true, isLeft: false)),
                    const Positioned(bottom: 60, left: 40, child: CornerBracket(isTop: false, isLeft: true)),
                    const Positioned(bottom: 60, right: 40, child: CornerBracket(isTop: false, isLeft: false)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Point camera at the QR Code"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  const CornerBracket({super.key, required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double size = 30;
    const double thickness = 4;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(top: isTop ? 0 : null, bottom: isTop ? null : 0, left: isLeft ? 0 : null, right: isLeft ? null : 0, child: Container(width: size, height: thickness, color: Colors.green)),
          Positioned(top: isTop ? 0 : null, bottom: isTop ? null : 0, left: isLeft ? 0 : null, right: isLeft ? null : 0, child: Container(width: thickness, height: size, color: Colors.green)),
        ],
      ),
    );
  }
}