import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverScheduleScreen extends StatelessWidget {
  const DriverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color brandGreen = Color(0xFF1B5E36);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Trip History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('schedules')
                  .where('driverId', isEqualTo: user.email)
                  .where('status', isEqualTo: 'Completed') 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: brandGreen));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 15),
                        const Text("No completed trips found.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                var completedTasks = snapshot.data!.docs.toList();
                
                
                completedTasks.sort((a, b) {
                  var aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  var bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); 
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    var data = completedTasks[index].data() as Map<String, dynamic>;
                    String routeName = data['route'] ?? 'Unknown Route';
                    String date = data['date'] ?? 'N/A';
                    String time = data['time'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(Icons.check_circle, color: brandGreen),
                        ),
                        title: Text(routeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "📅 $date  |  ⏰ $time\n✅ Status: Completed", 
                            style: const TextStyle(color: Colors.black54, height: 1.4)
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}