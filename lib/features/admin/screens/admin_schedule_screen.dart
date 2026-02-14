import 'package:flutter/material.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

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
          'Collection Schedule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Today's Tasks"),
          const SizedBox(height: 12),
          _buildScheduleCard(
            date: "Feb 14, 2026",
            time: "09:00 AM",
            driver: "Asanka Perera",
            blocks: "Block A & B",
            status: "In Progress",
            statusColor: Colors.blue,
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("Upcoming Pickups"),
          const SizedBox(height: 12),
          _buildScheduleCard(
            date: "Feb 16, 2026",
            time: "07:30 AM",
            driver: "Saman Kumara",
            blocks: "Block C, D & E",
            status: "Scheduled",
            statusColor: Colors.orange,
          ),
          _buildScheduleCard(
            date: "Feb 18, 2026",
            time: "07:30 AM",
            driver: "Not Assigned",
            blocks: "Basement Chutes",
            status: "Pending",
            statusColor: Colors.red,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: brandGreen,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Scheduling feature coming soon!")),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildScheduleCard({
    required String date,
    required String time,
    required String driver,
    required String blocks,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          _buildDetailRow(Icons.access_time_filled_rounded, "Time", time),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.person_pin_rounded, "Driver", driver),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.location_on_rounded, "Route", blocks),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}
