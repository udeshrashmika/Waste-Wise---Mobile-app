import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

 
  Color _getStatusColor(String status) {
    if (status == 'Full') return Colors.red;
    if (status == 'Half-Full') return Colors.orange;
    return const Color(0xFF1B5E36); 
  }

  
  double _getDisplayLevel(String status) {
    if (status == 'Full') return 1.0; 
    if (status == 'Half-Full') return 0.5; 
    return 0.05; 
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Waste-Wise Overview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bins').snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong! ⚠️'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          final docs = snapshot.data!.docs;
          
          int totalPoints = docs.length;
          
          int fullBins = docs.where((doc) => doc['status'] == 'Full').length;
          
          int halfFullBins = docs.where((doc) => doc['status'] == 'Half-Full').length;
          
          int activeDrivers = 1; 

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Pulse",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

               
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard("Total Points", "$totalPoints", brandGreen),
                    _buildStatCard("Full Bins", "$fullBins", Colors.red),
                    _buildStatCard("Half-Full", "$halfFullBins", Colors.orange),
                    _buildStatCard("Active Drivers", "$activeDrivers", Colors.blue),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Garbage Point Locations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                
                Column(
                  children: docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    
                    
                    String locationName = data['location'] ?? 'Unknown Location'; 
                    String status = data['status'] ?? 'Empty';

                    return _buildLocationTile(
                      locationName,
                      _getDisplayLevel(status),
                      _getStatusColor(status),
                      status,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String location, double level, Color color, String statusText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Text(
                statusText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: level,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}