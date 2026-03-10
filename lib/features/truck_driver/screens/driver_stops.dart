import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key});


  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapsAppUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final Uri browserUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

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
    
  

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Stops List", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      
     
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bins') 
            
           
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
                  Icon(Icons.delete_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("No bins to collect!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var bin = snapshot.data!.docs[index];
              var data = bin.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.delete, color: Colors.green),
                  ),
                  title: Text(
                    
                    data['locationName'] ?? 'Unknown Bin',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    
                    "Block: ${data['blockID'] ?? 'Unknown'} | Status: ${data['status'] ?? 'N/A'}"
                  ),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                       
                      
                      double lat = data['lat'] ?? 0.0;
                      double lng = data['lng'] ?? 0.0;
                      _openMap(lat, lng);
                    },
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text("Navigate"),
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