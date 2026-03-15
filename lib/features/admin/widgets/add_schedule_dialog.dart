import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String? selectedDriverId;
  String? selectedDriverName;
  String? selectedRoute;

  bool isLoading = false;

  final Color brandGreen = const Color(0xFF1B5E36);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: brandGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        List<String> months = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];
        _dateController.text = "${months[picked.month - 1]} ${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: brandGreen)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (mounted) {
        setState(() {
          _timeController.text = picked.format(context);
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (selectedDriverId == null ||
        selectedRoute == null ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a route!"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('schedules').add({
        'driverId': selectedDriverId,
        'driverName': selectedDriverName,
        'route': selectedRoute,
        'date': _dateController.text,
        'time': _timeController.text,
        'status': 'Scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Schedule Added Successfully! ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding schedule: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "New Collection Task",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Truck Driver')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();

                  var drivers = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Driver",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: brandGreen),
                      ),
                    ),
                    value: selectedDriverId,
                    items: drivers.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: data['email'],
                        child: Text(data['name'] ?? 'Unknown Driver'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDriverId = value;
                        selectedDriverName = drivers.firstWhere(
                          (d) => (d.data() as Map)['email'] == value,
                        )['name'];
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bins')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No bins available in database.");
                  }

                  var bins = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Select Route (Bin)",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: brandGreen),
                      ),
                    ),
                    value: selectedRoute,
                    items: bins.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String locationName = data['locationName'] ?? doc.id;

                      return DropdownMenuItem<String>(
                        value: locationName,
                        child: Text(locationName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRoute = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Select Date",
                  suffixIcon: Icon(
                    Icons.calendar_month_rounded,
                    color: brandGreen,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: brandGreen),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: InputDecoration(
                  labelText: "Select Time",
                  suffixIcon: Icon(
                    Icons.access_time_rounded,
                    color: brandGreen,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: brandGreen),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: brandGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
