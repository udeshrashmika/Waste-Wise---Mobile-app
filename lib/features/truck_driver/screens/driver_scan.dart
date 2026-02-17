import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class DriverScanScreen extends StatefulWidget {
  const DriverScanScreen({super.key});

  @override
  State<DriverScanScreen> createState() => _DriverScanScreenState();
}

class _DriverScanScreenState extends State<DriverScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool isScanned = false; 

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
   onDetect: (capture) {
  if (!isScanned) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      setState(() {
        isScanned = true;
      });

     

      
      String rawQr = barcode.rawValue ?? "Unknown_Bin";
      
      String binId = rawQr.replaceAll(RegExp(r'[^\w\s]+'), '_'); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing... Please wait ⏳")),
      );
                            
                            FirebaseFirestore.instance.collection('bins').doc(binId).set({
                              'bin_id': binId,
                              'status': 'Empty', 
                              'last_collected': FieldValue.serverTimestamp(),
                              'collected_by': 'Driver Asanka', 
                              'location': 'Block A', 
                              'fill_level': 0,
                            }, SetOptions(merge: true)).then((_) {
                              
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Success! Bin $binId Collected ✅"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  isScanned = false;
                                });
                              });

                            }).catchError((error) {
                             
                              setState(() {
                                isScanned = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to update: $error"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
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
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: size, height: thickness, color: Colors.green),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: thickness, height: size, color: Colors.green),
          ),
        ],
      ),
    );
  }
}