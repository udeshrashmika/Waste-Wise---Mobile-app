import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.4,
              children: const [
                _StatCard(title: "Total Disposal Points", value: "28", icon: Icons.delete_outline, color: Colors.black),
                _StatCard(title: "Active Truck Pickup", value: "12", icon: Icons.local_shipping_outlined, color: Colors.black),
                _StatCard(title: "Bin Sites Detected", value: "5", icon: Icons.warning_amber_rounded, isAlert: true, color: Colors.red),
                _StatCard(title: "Avg. Collection Compliance", value: "92%", icon: Icons.check_circle_outline, color: Colors.black),
              ],
            ),
            const SizedBox(height: 25),

            
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  
                  image: NetworkImage('https://tile.openstreetmap.org/13/5863/3864.png'), 
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ),
            const SizedBox(height: 25),

            
            const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildActivityItem("Full Bin Detected", "Apartment Block A", Colors.red),
            _buildActivityItem("Pickup Completed", "Route #12345", Colors.green),
            _buildActivityItem("New Resident Added", "User ID: 8892", Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.circle, color: color, size: 15),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isAlert;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, this.isAlert = false, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFFF0F0) : const Color(0xFFF5F9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}