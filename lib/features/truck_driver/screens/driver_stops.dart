import 'package:flutter/material.dart';

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stops"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: const Icon(Icons.location_on_outlined, size: 30),
              title: Text(
                "Disposal Point ${index + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("123 Main Street, Colombo"),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
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
