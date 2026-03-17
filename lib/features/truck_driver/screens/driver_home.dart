import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  LatLng? currentLoc;
  LatLng? destLoc;
  String? _loadedRoute;

  @override
  void initState() {
    super.initState();
    _startLiveLocation();
  }

  Future<void> _startLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        currentLoc = LatLng(position.latitude, position.longitude);
      });
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          currentLoc = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  Future<void> _fetchDestinationLoc(String locationName) async {
    if (_loadedRoute == locationName) return;
    _loadedRoute = locationName;

    try {
      var binSnapshot = await FirebaseFirestore.instance
          .collection('bins')
          .where('locationName', isEqualTo: locationName)
          .limit(1)
          .get();

      if (binSnapshot.docs.isNotEmpty) {
        var binData = binSnapshot.docs.first.data();
        double lat = 0.0, lng = 0.0;

        if (binData['Location'] is GeoPoint) {
          lat = (binData['Location'] as GeoPoint).latitude;
          lng = (binData['Location'] as GeoPoint).longitude;
        } else {
          lat = (binData['lat'] ?? 0.0).toDouble();
          lng = (binData['lng'] ?? 0.0).toDouble();
        }

        if (mounted && lat != 0.0 && lng != 0.0) {
          setState(() {
            destLoc = LatLng(lat, lng);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching destination: $e");
    }
  }

  Future<void> _openNavigationMap(
    BuildContext context,
    String locationName,
  ) async {
    try {
      if (destLoc != null) {
        double lat = destLoc!.latitude;
        double lng = destLoc!.longitude;

        if (await canLaunchUrl(
          Uri.parse("google.navigation:q=$lat,$lng&mode=d"),
        )) {
          await launchUrl(Uri.parse("google.navigation:q=$lat,$lng&mode=d"));
        } else {
          await launchUrl(
            Uri.parse(
              "http://googleusercontent.com/maps.google.com/?q=$lat,$lng",
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        await launchUrl(
          Uri.parse(
            "http://googleusercontent.com/maps.google.com/?q=${Uri.encodeComponent(locationName)}",
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not open map.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Today's Route",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .where('driverId', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoTasksUI();
          }

          var allTasks = snapshot.data!.docs;

          var activeTasks = allTasks.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['status'] != 'Completed';
          }).toList();

          activeTasks.sort((a, b) {
            var aTime =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            var bTime =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return aTime.compareTo(bTime);
          });

          if (activeTasks.isEmpty) {
            return _buildNoTasksUI();
          }

          var task = activeTasks.first;
          Map<String, dynamic> data = task.data() as Map<String, dynamic>;
          String routeName = data['route'] ?? 'Unknown Route';

          if (routeName != 'Unknown Route') {
            _fetchDestinationLoc(routeName);
          }

          return Padding(
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
                      const Text(
                        "Route Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildRouteRow(
                        Icons.explore_outlined,
                        "Route Name",
                        routeName,
                      ),
                      const SizedBox(height: 15),
                      _buildRouteRow(
                        Icons.access_time_rounded,
                        "Time",
                        "${data['date']} at ${data['time']}",
                      ),
                      const SizedBox(height: 15),
                      _buildRouteRow(
                        Icons.info_outline,
                        "Status",
                        data['status'] ?? 'Scheduled',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: (currentLoc == null || destLoc == null)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 20),
                                  Text(
                                    currentLoc == null
                                        ? "❌ Waiting for Live GPS..."
                                        : "✅ Live GPS Found!",
                                    style: TextStyle(
                                      color: currentLoc == null
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    destLoc == null
                                        ? "❌ Waiting for Bin Location..."
                                        : "✅ Bin Location Found!",
                                    style: TextStyle(
                                      color: destLoc == null
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: currentLoc!,
                                initialZoom: 14.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.waste_wise',
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [currentLoc!, destLoc!],
                                      strokeWidth: 4.0,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: currentLoc!,
                                      child: const Icon(
                                        Icons.local_shipping,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                    ),
                                    Marker(
                                      point: destLoc!,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('schedules')
                            .doc(task.id)
                            .update({'status': 'In Progress'});
                        if (context.mounted) {
                          _openNavigationMap(context, routeName);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    },
                    child: const Text(
                      "CONFIRM PICKUP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoTasksUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 10),
          const Text(
            "No active tasks! You're all caught up.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
