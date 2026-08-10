import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegisterMode = false;
  bool isObscurePassword = true;
  bool isLoading = false;

  final _namaTokoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleAuthSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final namaToko = _namaTokoController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Isi email dan password!', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isRegisterMode) {
        if (namaToko.isEmpty) {
          _showSnackBar('Isi Nama Toko Laundry Anda!', isError: true);
          setState(() => isLoading = false);
          return;
        }

        final tokoRes = await SupabaseService.client.from('toko').insert({
          'nama_toko': namaToko,
        }).select().single();

        final authRes = await SupabaseService.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'toko_id': tokoRes['id'],
            'role': 'owner',
            'nama_user': 'Owner $namaToko',
          },
        );

        if (authRes.user != null) {
          _showSnackBar('Pendaftaran Toko Berhasil! Silakan Login.');
          setState(() => isRegisterMode = false);
        }
      } else {
        final res = await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null && mounted) {
          _showSnackBar('Login Berhasil! Selamat Datang.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_laundry_service, size: 50, color: Color(0xFF2563EB)),
                const SizedBox(height: 8),
                const Text(
                  'LNDR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  isRegisterMode ? 'Daftarkan Toko Laundry Anda' : 'Masuk ke akun LNDR Anda',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                if (isRegisterMode) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nama Toko Laundry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _namaTokoController,
                    decoration: InputDecoration(
                      hintText: 'contoh: LNDR Cabang Utama',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700])),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'owner@lndr.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700])),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _passwordController,
                  obscureText: isObscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(isObscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => isObscurePassword = !isObscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isLoading ? null : _handleAuthSubmit,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            isRegisterMode ? 'DAFTAR TOKO BARU' : 'LOG IN',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => setState(() => isRegisterMode = !isRegisterMode),
                  child: Text(
                    isRegisterMode ? 'Sudah punya akun? Log In Kasir/Owner' : 'Belum punya akun? Daftar Toko Baru (Owner)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
