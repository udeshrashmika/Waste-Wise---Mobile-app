import 'package:flutter/material.dart';

// Ensure these paths match your folder structure exactly
import 'features/auth/screens/role_selection_screen.dart';

void main() {
  // Required if you add Firebase or any native plugins later
  WidgetsFlutterBinding.ensureInitialized();
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
        // Using SeedColor ensures all widgets (buttons, switches, etc.)
        // use your NSBM Green branding automatically.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E36), // Deep Green
          primary: const Color(0xFF2D8B49), // Action Green
          surface: Colors.white,
        ),

        // Ensure you add 'Inter' font to your pubspec.yaml
        fontFamily: 'Inter',

        // Global Button Style to match your Figma buttons
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
