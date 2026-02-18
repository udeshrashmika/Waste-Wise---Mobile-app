import 'package:flutter/material.dart';
import '../../../core/services/admin_management_service.dart';

class AddDriverDialog extends StatefulWidget {
  const AddDriverDialog({super.key});
  @override
  State<AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<AddDriverDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _service = AdminManagementService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Register New Driver"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email Address"),
            ),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(labelText: "Vehicle Number"),
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
            if (_emailController.text.isNotEmpty) {
              await _service.inviteDriver(
                _nameController.text,
                _emailController.text,
                _vehicleController.text,
              );
              Navigator.pop(context);
            }
          },
          child: const Text("Invite"),
        ),
      ],
    );
  }
}
