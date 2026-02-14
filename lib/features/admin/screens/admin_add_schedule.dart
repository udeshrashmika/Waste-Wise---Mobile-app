import 'package:flutter/material.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  List<Map<String, String>> schedules = [
    {
      "title": "Apartment Block A",
      "waste": "Mon, Wed, Fri",
      "recycling": "Every Sunday",
      "organic": "Every Friday"
    },
    {
      "title": "Apartment Block B",
      "waste": "Tue, Thu, Sat",
      "recycling": "Every Monday",
      "organic": "Every Saturday"
    },
    {
      "title": "Lake View Apartments",
      "waste": "Daily",
      "recycling": "Every Wednesday",
      "organic": "Every Sunday"
    },
  ];

  void _showScheduleForm({int? index}) {
    bool isEditing = index != null;
    Map<String, String> data = isEditing
        ? schedules[index]
        : {"title": "", "waste": "", "recycling": "", "organic": ""};

    TextEditingController titleCtrl = TextEditingController(text: data['title']);
    TextEditingController wasteCtrl = TextEditingController(text: data['waste']);
    TextEditingController recyclingCtrl = TextEditingController(text: data['recycling']);
    TextEditingController organicCtrl = TextEditingController(text: data['organic']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Edit Schedule" : "Add New Schedule"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleCtrl, "Apartment Name"),
              const SizedBox(height: 10),
              _buildTextField(wasteCtrl, "Waste Disposal (e.g. Mon, Wed)"),
              const SizedBox(height: 10),
              _buildTextField(recyclingCtrl, "Recycling Collection"),
              const SizedBox(height: 10),
              _buildTextField(organicCtrl, "Organic Waste Pickup"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E36)),
            onPressed: () {
              setState(() {
                Map<String, String> newSchedule = {
                  "title": titleCtrl.text,
                  "waste": wasteCtrl.text,
                  "recycling": recyclingCtrl.text,
                  "organic": organicCtrl.text,
                };

                if (isEditing) {
                } else {
                }
              });
              Navigator.pop(context);
            },
            child: Text(isEditing ? "Save Changes" : "Add", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  void _deleteSchedule(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Schedule?"),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                schedules.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Schedule Manager", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: schedules.isEmpty
          ? const Center(child: Text("No schedules added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                return _buildScheduleCard(index, schedules[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleForm(),
        backgroundColor: const Color(0xFF1B5E36),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Schedule", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildScheduleCard(int index, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E36))),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showScheduleForm(index: index),
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => _deleteSchedule(index),
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          _buildRow(Icons.delete_outline, "Waste Disposal", data['waste']!),
          const SizedBox(height: 12),
          _buildRow(Icons.recycling, "Recycling Collection", data['recycling']!),
          const SizedBox(height: 12),
          _buildRow(Icons.eco_outlined, "Organic Waste Pickup", data['organic']!),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2D8B49)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}