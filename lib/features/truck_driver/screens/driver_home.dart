import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_wise/features/truck_driver/screens/driver_main_layout.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  
  final LatLng currentLoc = const LatLng(6.9344, 79.8428); 
  final LatLng destLoc = const LatLng(6.9147, 79.8516); 

  
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Today's Route", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedules') 
            .where('driverId', isEqualTo: user?.uid) 
            .where('status', isEqualTo: 'Pending') 
            .snapshots(),
        builder: (context, snapshot) {
          
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade200),
                  const SizedBox(height: 20),
                  const Text("No active tasks! You're all caught up.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

         
          var task = snapshot.data!.docs.first; 
          Map<String, dynamic> data = task.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    children: [
                      const Text("Route Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                     
                      _buildInfoRow(Icons.map, "Route", data['route'] ?? 'Unknown Route'),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.timelapse, "Time", data['time'] ?? '00:00'),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.info_outline, "Status", data['status'] ?? 'Pending'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: currentLoc, 
                          initialZoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.waste_wise',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(points: [currentLoc, destLoc], strokeWidth: 4.0, color: Colors.blue),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(point: currentLoc, child: const Icon(Icons.local_shipping, color: Colors.blue, size: 40)),
                              Marker(point: destLoc, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverMainLayout(initialIndex: 1),
                        ),
                      );
                    },
                    child: const Text("CONFIRM PICKUP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}