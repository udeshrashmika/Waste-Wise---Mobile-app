import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/admin_schedule_screen.dart';

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final AdminScheduleService _service = AdminScheduleService();
  final _routeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String? selectedDriverId;
  String? selectedDriverName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Collection Task"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _service.getAvailableDrivers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                var drivers = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  hint: const Text("Select Driver"),
                  items: drivers.map((d) {
                    Map<String, dynamic> data =
                        d.data() as Map<String, dynamic>;
                    String name = data.containsKey('name')
                        ? data['name']
                        : 'Unknown Driver';

                    return DropdownMenuItem(value: d.id, child: Text(name));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedDriverId = val;
                      var doc =
                          drivers.firstWhere((d) => d.id == val).data()
                              as Map<String, dynamic>;
                      selectedDriverName = doc.containsKey('name')
                          ? doc['name']
                          : 'Unknown Driver';
                    });
                  },
                );
              },
            ),
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(labelText: "Route"),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Date (e.g., Feb 20)",
              ),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: "Time (e.g., 08:00 AM)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedDriverId != null && _routeController.text.isNotEmpty) {
              await _service.addSchedule(
                driverId: selectedDriverId!,
                driverName: selectedDriverName!,
                route: _routeController.text,
                date: _dateController.text,
                time: _timeController.text,
              );
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
