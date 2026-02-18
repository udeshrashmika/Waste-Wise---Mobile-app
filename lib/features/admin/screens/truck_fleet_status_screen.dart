import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/admin_management_service.dart';
import '../widgets/add_driver_dialog.dart';

class TruckFleetStatusScreen extends StatelessWidget {
  final AdminManagementService _service = AdminManagementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Truck Fleet Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getDrivers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var drivers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              var data = drivers[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1B5E36),
                    child: Icon(Icons.local_shipping, color: Colors.white),
                  ),
                  title: Text(
                    data['name'] ?? 'Unknown Driver',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Vehicle: ${data['vehicleNumber'] ?? 'N/A'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _service.removeUser(drivers[index].id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E36),
        onPressed: () => showDialog(
          context: context,
          builder: (c) => const AddDriverDialog(),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
