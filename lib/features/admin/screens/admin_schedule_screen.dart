import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/add_schedule_dialog.dart';

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No schedules found. Click + to add."),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var data = tasks[index].data() as Map<String, dynamic>;

              Color statusColor;
              switch (data['status']) {
                case 'In Progress':
                  statusColor = Colors.blue;
                  break;
                case 'Scheduled':
                  statusColor = Colors.orange;
                  break;
                default:
                  statusColor = Colors.red;
              }

              return _buildScheduleCard(
                date: data['date'] ?? 'No Date',
                time: data['time'] ?? 'No Time',
                driver: data['driverName'] ?? 'Not Assigned',
                blocks: data['route'] ?? 'No Route',
                status: data['status'] ?? 'Pending',
                statusColor: statusColor,
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: brandGreen,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddScheduleDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
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

class AdminScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAvailableDrivers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'Truck Driver')
        .snapshots();
  }

  Future<void> addSchedule({
    required String driverId,
    required String driverName,
    required String route,
    required String date,
    required String time,
  }) async {
    await _db.collection('schedules').add({
      'driverId': driverId,
      'driverName': driverName,
      'route': route,
      'date': date,
      'time': time,
      'status': 'Scheduled',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
