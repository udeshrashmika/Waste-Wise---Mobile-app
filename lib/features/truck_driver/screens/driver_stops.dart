import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key});

  
  Future<void> _openMap(double lat, double lng) async {
    
    final Uri googleMapsAppUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    
    
    final Uri browserUrl = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    try {
      if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl);
      } else {
        
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> stops = [
      {"name": "Town Hall Bin", "address": "Viharamahadevi Park, Colombo", "lat": 6.9147, "lng": 79.8616},
      {"name": "Lotus Tower Bin", "address": "D.R. Wijewardena Mw, Colombo", "lat": 6.9271, "lng": 79.8612},
      {"name": "Pettah Market Bin", "address": "Main Street, Colombo 11", "lat": 6.9366, "lng": 79.8479},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stops List"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.location_on, color: Colors.green),
              ),
              title: Text(
                stop['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(stop['address']),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  
                  _openMap(stop['lat'], stop['lng']);
                },
                icon: const Icon(Icons.navigation, size: 16),
                label: const Text("Navigator"),
              ),
            ),
          );
        },
      ),
    );
  }
}