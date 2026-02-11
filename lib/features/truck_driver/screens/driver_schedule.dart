import 'package:flutter/material.dart';

class DriverScheduleScreen extends StatelessWidget {
  const DriverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Schedule",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Today"),
          _buildTripCard("Trip #12345", "11.30 AM", "8.00 AM"),
          _buildTripCard("Trip #12346", "4.45 AM", "8.00 AM"),
          const SizedBox(height: 20),
          _buildSectionHeader("Yesterday"),
          _buildTripCard("Trip #12347", "11.30 AM", "8.00 AM"),
          _buildTripCard("Trip #12348", "11.30 AM", "8.00 AM"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTripCard(
    String tripId,
    String completedTime,
    String startedTime,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFF5F5F5),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, size: 40, color: Colors.black),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Completed: $completedTime",
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  "Started: $startedTime",
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
