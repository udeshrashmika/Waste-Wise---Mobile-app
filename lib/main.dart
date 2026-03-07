import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'services/classifier_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await ClassifierService.loadModel();
    print("AI Model loaded successfully");
  } catch (e) {
    print("Error loading AI Model: $e");
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
      home: const RoleSelectionScreen(),
    );
  }
}
