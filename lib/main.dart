import 'package:flutter/material.dart';

import 'features/auth/screens/role_selection_screen.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E36),
          primary: const Color(0xFF2D8B49),
        ),

        fontFamily: 'Inter',
      ),

      home: const RoleSelectionScreen(),
    );
  }
}
