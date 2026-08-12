 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import 'package:pocketbase/pocketbase.dart';
 
 import 'providers/settings_provider.dart';
 import 'screens/kasir_home_screen.dart';
 
 final pb = PocketBase('http://127.0.0.1:8090');
 
 void main() {
   WidgetsFlutterBinding.ensureInitialized();
   runApp(const MyApp());
 }
 
 class MyApp extends StatelessWidget {
   const MyApp({super.key});
 
   @override
   Widget build(BuildContext context) {
     return MultiProvider(
       providers: [
         ChangeNotifierProvider(create: (_) => SettingsProvider()),
       ],
       child: MaterialApp(
         title: 'LNDR Kasir',
         debugShowCheckedModeBanner: false,
         theme: ThemeData(
           primarySwatch: Colors.blue,
           useMaterial3: true,
         ),
         home: const KasirHomeScreen(),
       ),
     );
   }
 }
