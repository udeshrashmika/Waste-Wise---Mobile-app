import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverScheduleScreen extends StatelessWidget {
  const DriverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentDriverId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Trip History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .where('driverId', isEqualTo: currentDriverId)
            .where('status', isEqualTo: 'Completed')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed trips found."));
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              var data = trips[index].data() as Map<String, dynamic>;

              return _buildTripCard(
                data['route'] ?? "Unknown Route",
                data['time'] ?? "N/A",
                data['date'] ?? "N/A",
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(String route, String time, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFF5F5F5),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.history, size: 40, color: Color(0xFF1B5E20)), //
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Completed: $date",
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  "Scheduled Time: $time",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
