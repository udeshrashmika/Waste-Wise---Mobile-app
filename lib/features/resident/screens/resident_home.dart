import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_bin_screen.dart';

class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Waste Wise',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 24),

            _buildAIScanButton(context, brandGreen),

            const SizedBox(height: 24),

            
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildBinStatusCard("Loading...", Colors.grey);
                }

                String status = "Empty";
                Color statusColor = brandGreen;

                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  status = userData['currentBinLevel'] ?? "Empty";

                  if (status == "Full") {
                    statusColor = Colors.red;
                  } else if (status == "Half Full") {
                    statusColor = Colors.orange;
                  }
                }

                return _buildBinStatusCard(status, statusColor);
              },
            ),

            const SizedBox(height: 24),

            
            _buildScheduleCard(),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              Icons.check_circle,
              Colors.green,
              'Disposal Completed',
              'Your waste was collected successfully.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIScanButton(BuildContext context, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadBinScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text(
              'Analyze Bin Level',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Point camera at your bin',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinStatusCard(String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last Known Bin Level",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.delete_sweep_rounded, color: statusColor, size: 40),
        ],
      ),
    );
  }


  Widget _buildScheduleCard() {
    return StreamBuilder<QuerySnapshot>(
      
      stream: FirebaseFirestore.instance.collection('schedules').snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error!: ${snapshot.error}", style: const TextStyle(color: Colors.red));
        }

        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNextCollectionUI("No Data Found!", "", "");
        }

        
        
        var allDocs = snapshot.data!.docs;
        var scheduledDocs = allDocs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['status']?.toString().trim() == 'Scheduled'; 
        }).toList();

        
        if (scheduledDocs.isEmpty) {
          var firstDocData = allDocs.first.data() as Map<String, dynamic>;
          String wrongStatus = firstDocData['status']?.toString() ?? 'No Status Field';
          return _buildNextCollectionUI("Word Mismatch!", "Database එකේ තියෙන වචනේ: '$wrongStatus'", "");
        }

        
        var data = scheduledDocs.first.data() as Map<String, dynamic>;
        String date = data['date'] ?? "Unknown Date";
        String time = data['time'] ?? "Unknown Time";
        String route = data['route'] ?? "";

        return _buildNextCollectionUI(date, "Pickup starts at $time", route);
      },
    );
  }

  Widget _buildNextCollectionUI(String title, String subtitle, String route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(color: Colors.blue, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT COLLECTION',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (route.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Route: $route',
              style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}