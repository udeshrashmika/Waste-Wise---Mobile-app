import 'package:flutter/material.dart';

class TruckFleetStatusScreen extends StatelessWidget {
  const TruckFleetStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Truck Fleet Status",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTruckTile(
            "Truck #01",
            "Asanka Perera",
            "On Route",
            Colors.blue,
          ),
          _buildTruckTile(
            "Truck #02",
            "Saman Kumara",
            "Standby",
            Colors.orange,
          ),
          _buildTruckTile(
            "Truck #03",
            "Dilshan Silva",
            "Maintenance",
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTruckTile(
    String truck,
    String driver,
    String status,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.local_shipping, color: color, size: 30),
        title: Text(truck, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Driver: $driver"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
