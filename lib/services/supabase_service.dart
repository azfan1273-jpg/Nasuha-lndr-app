import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Masukkan URL dan Anon Key project Supabase kamu di sini
  static const String supabaseUrl = 'https://qsiuzkuhtgkhusrmozut.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_oi4dBcSnj9bEjif2cIcnKw_W_X0H0LN';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
