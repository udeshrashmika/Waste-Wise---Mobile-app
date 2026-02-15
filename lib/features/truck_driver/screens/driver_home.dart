import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  
  final LatLng pickupLocation = const LatLng(6.9271, 79.8612);

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
      body: Padding(
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
                  _buildRouteRow(Icons.explore_outlined, "Route Name", "Colombo Central (ID: 12345)"),
                  const SizedBox(height: 15),
                  _buildRouteRow(Icons.back_hand_rounded, "Total Stops", "10 Stops"),
                  const SizedBox(height: 15),
                  _buildRouteRow(Icons.access_time_rounded, "Estimated Time", "4 hours"),
                ],
              ),
            ),
            const SizedBox(height: 25),

            
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: pickupLocation, 
                      initialZoom: 15.0, 
                    ),
                    children: [
                     
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.waste_wise',
                      ),
                      
                      
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pickupLocation,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on, 
                              color: Colors.red, 
                              size: 50,
                            ),
                          ),
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
                onPressed: () {},
                child: const Text("CONFIRM PICKUP",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, String label, String value) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}