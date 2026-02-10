import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'firebase_options.dart'; // Add this (the file flutterfire just created)

// Ensure these paths match your folder structure exactly
import 'features/auth/screens/role_selection_screen.dart';

void main() async {
  // Added 'async'
  // Required for Firebase and other native plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the settings for the current platform (Android/iOS/Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const WasteWiseApp());
}

class WasteWiseApp extends StatelessWidget {
  const WasteWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WASTE WISE',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E36), // Deep Green
          primary: const Color(0xFF2D8B49), // Action Green
          surface: Colors.white,
        ),

        fontFamily: 'Inter',

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Entry point of the App
      home: const RoleSelectionScreen(),
    );
  }
}
