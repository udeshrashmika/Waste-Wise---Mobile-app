import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Upcoming Stops", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('schedules').where('driverId', isEqualTo: user.email).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState();

                
                var pendingTasks = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] != 'Completed').toList();
                
                pendingTasks.sort((a, b) {
                  var aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  var bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return aTime.compareTo(bTime);
                });

                
                if (pendingTasks.length <= 1) return _buildEmptyState();

                
                var upcomingTasks = pendingTasks.skip(1).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: upcomingTasks.length,
                  itemBuilder: (context, index) {
                    var data = upcomingTasks[index].data() as Map<String, dynamic>;
                    String routeName = data['route'] ?? 'Unknown Route';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade50,
                          child: Text("${index + 2}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        title: Text(routeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("📅 ${data['date']}  |  ⏰ ${data['time']}", style: const TextStyle(color: Colors.black54)),
                        ),
                        trailing: const Chip(
                          label: Text("Waiting", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFFFFF3E0),
                          side: BorderSide.none,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pending_actions_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text("No Upcoming Stops", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("All clear after your current task!", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}