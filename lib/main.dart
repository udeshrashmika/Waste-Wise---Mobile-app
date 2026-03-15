import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/resident/screens/resident_main_layout.dart';
import 'features/admin/screens/admin_main_layout.dart';
import 'features/truck_driver/screens/driver_main_layout.dart';

import 'services/classifier_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await ClassifierService.loadModel();
    print("✅ AI Model loaded successfully");
  } catch (e) {
    print("❌ Error loading AI Model: $e");
  }

  runApp(const WasteWiseApp());
}

class WasteWiseApp extends StatelessWidget {
  const WasteWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WasteWise',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E36),
          primary: const Color(0xFF2D8B49),
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                String role = userSnapshot.data!['role'];

                if (role == 'Admin') return const AdminMainLayout();
                if (role == 'Truck Driver') return const DriverMainLayout();
                if (role == 'Resident') return const ResidentMainLayout();
              }

              return const UniversalLoginScreen();
            },
          );
        }

        return const UniversalLoginScreen();
      },
    );
  }
}