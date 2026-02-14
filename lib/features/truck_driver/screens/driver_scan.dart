import 'package:flutter/material.dart';

class DriverScanScreen extends StatelessWidget {
  const DriverScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Final disposal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
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
            const SizedBox(height: 40),

           
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "Camera View Placeholder",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    left: 20,
                    child: CornerBracket(isTop: true, isLeft: true),
                  ),
                  const Positioned(
                    top: 20,
                    right: 20,
                    child: CornerBracket(isTop: true, isLeft: false),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 20,
                    child: CornerBracket(isTop: false, isLeft: true),
                  ),
                  const Positioned(
                    bottom: 20,
                    right: 20,
                    child: CornerBracket(isTop: false, isLeft: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Confirm Disposal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
}

class CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  const CornerBracket({super.key, required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    const double thickness = 5;
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
            child: Container(
              width: size,
              height: thickness,
              color: Colors.green,
            ),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              height: size,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
