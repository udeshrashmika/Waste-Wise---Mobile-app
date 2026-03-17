import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);
    
    
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alerts & Activity',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      body: uid == null 
        ? const Center(child: Text("Please log in to view alerts."))
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandGreen));
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: Text("User profile not found."));
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              
              
              String userBlock = userData['apartmentId'] ?? 'Unknown'; 

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    
                    .where('blockID', isEqualTo: userBlock) 
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading alerts"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: brandGreen));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No new alerts for $userBlock."));
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var data = notifications[index].data() as Map<String, dynamic>;

                      return _buildNotificationCard(
                        icon: _getIconForType(data['type']),
                        iconColor: _getColorForType(data['type'], brandGreen),
                        title: data['title'] ?? 'Update',
                        message: data['message'] ?? '',
                        time: _formatTimestamp(data['timestamp']),
                      );
                    },
                  );
                },
              );
            },
          ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'collection': return Icons.check_circle_rounded;
      case 'warning': return Icons.error_outline_rounded;
      case 'schedule': return Icons.calendar_month_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String? type, Color brand) {
    if (type == 'warning') return Colors.orange;
    if (type == 'schedule') return Colors.blue;
    return brand;
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return "Just now";
    }
    return DateFormat('jm').format(dateTime);
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}