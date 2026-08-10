import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Supabase
  await SupabaseService.init();

  runApp(const LndrKasirApp());
}

class LndrKasirApp extends StatelessWidget {
  const LndrKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LNDR Kasir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: AuthScreen(), // Tanpa kata const
    );
  }
}
