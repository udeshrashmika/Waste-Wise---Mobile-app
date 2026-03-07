import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Disposal History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('disposal_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading history"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("තාම History එකක් නැහැ."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Document එක සහ ඒකේ ID එක වෙන වෙනම ගන්නවා
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id; // මේක තමයි Delete කරන්න ඕන ID එක

              String formattedDate = "Just Now";
              if (data['timestamp'] != null) {
                DateTime date = (data['timestamp'] as Timestamp).toDate();
                formattedDate = "${date.day}/${date.month}/${date.year}";
              }

              String status = data['status'] ?? "Unknown";
              bool isCollected = data['isCollected'] ?? false;

              // Swipe to Delete පහසුකම සඳහා Dismissible භාවිතා කිරීම
              return Dismissible(
                key: Key(docId), // හැම item එකකටම unique key එකක් ඕන
                direction:
                    DismissDirection.endToStart, // දකුණේ ඉඳන් වමට Swipe කරන්න
                // Swipe කරද්දි පේන රතු පාට Background එක
                background: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                // Swipe කරලා ඉවර වුණාම වෙන දේ
                onDismissed: (direction) async {
                  // Firestore එකෙන් අදාළ record එක Delete කරනවා
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('disposal_history')
                      .doc(docId)
                      .delete();

                  // User ට Delete වුණා කියලා පොඩි පණිවිඩයක් පෙන්වනවා
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Record deleted successfully"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _buildHistoryCard(
                  date: formattedDate,
                  status: status,
                  isCollected: isCollected,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String status,
    required bool isCollected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF2D8B49),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Detection: $status",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCollected
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isCollected ? "Collected" : "Pending",
              style: TextStyle(
                color: isCollected ? Colors.green : Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
