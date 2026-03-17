import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }

          String residentBlock = "";
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            residentBlock =
                (userData['apartmentId'] ??
                        userData['blockID'] ??
                        userData['block'] ??
                        "")
                    .toString()
                    .trim();
          }

          if (residentBlock.isEmpty) {
            return const Center(
              child: Text("Block/Apartment ID not found for this user."),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                _buildAIScanButton(context, brandGreen),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Garbage Point Locations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bins')
                      .where('blockID', isEqualTo: residentBlock)
                      .snapshots(),
                  builder: (context, binSnapshot) {
                    if (binSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!binSnapshot.hasData ||
                        binSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Bins found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: binSnapshot.data!.docs.map((doc) {
                        var binData = doc.data() as Map<String, dynamic>;
                        String binName = doc.id;
                        String locationName = binData['locationName'] ?? "";
                        int levelCode = binData['levelCode'] ?? 0;

                        String status = "Empty";
                        Color statusColor = brandGreen;
                        double progressValue = 0.0;

                        if (levelCode == 2) {
                          status = "Full";
                          statusColor = Colors.red;
                          progressValue = 1.0;
                        } else if (levelCode == 1) {
                          status = "Half-Full";
                          statusColor = Colors.orange;
                          progressValue = 0.5;
                        } else {
                          status = "Empty";
                          statusColor = brandGreen;
                          progressValue = 0.0;
                        }

                        return _buildBinProgressCard(
                          binName,
                          locationName,
                          status,
                          statusColor,
                          progressValue,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('schedules')
                      .snapshots(),
                  builder: (context, scheduleSnapshot) {
                    if (scheduleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!scheduleSnapshot.hasData ||
                        scheduleSnapshot.data!.docs.isEmpty) {
                      return _buildNextCollectionUI(
                        "No Scheduled Pickups",
                        "Currently no upcoming collections.",
                        "",
                      );
                    }

                    var allSchedules = scheduleSnapshot.data!.docs;

                    var mySchedules = allSchedules.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String status = data['status']?.toString().trim() ?? "";
                      String route = data['route']?.toString().trim() ?? "";

                      return status == "Scheduled" &&
                          (route == residentBlock ||
                              route.contains(residentBlock));
                    }).toList();

                    if (mySchedules.isEmpty) {
                      return _buildNextCollectionUI(
                        "No Scheduled Pickups",
                        "Currently no upcoming collections.",
                        "",
                      );
                    }

                    return Column(
                      children: mySchedules.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String date = data['date'] ?? "Unknown Date";
                        String time = data['time'] ?? "Unknown Time";
                        String routeName = data['route'] ?? residentBlock;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildNextCollectionUI(
                            date,
                            "Pickup starts at $time",
                            routeName,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('blockID', isEqualTo: residentBlock)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, activitySnapshot) {
                    if (activitySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!activitySnapshot.hasData ||
                        activitySnapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "No recent activities",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    var allNotifications = activitySnapshot.data!.docs;

                    var collectionActivities = allNotifications.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return data['type'] == 'collection';
                    }).toList();

                    if (collectionActivities.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "No recent activities",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    var latestData =
                        collectionActivities.first.data()
                            as Map<String, dynamic>;

                    String timeString = _formatTimestamp(
                      latestData['timestamp'],
                    );

                    return _buildNotificationItem(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      title: latestData['title'] ?? 'Disposal Completed ✅',
                      subtitle:
                          latestData['message'] ??
                          'Your waste was collected successfully.',
                      time: timeString,
                      route: latestData['route'] ?? residentBlock,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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

  Widget _buildBinProgressCard(
    String binName,
    String locationName,
    String status,
    Color statusColor,
    double progressValue,
  ) {
    String displayName = locationName.isNotEmpty
        ? "$binName - $locationName"
        : binName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
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
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    String route = "",
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                if (route.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Route: $route',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return "Just now";
    }

    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}
