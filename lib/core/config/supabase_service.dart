import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  static const String supabaseUrl = 'https://jvxzvvxchrosbfygqfrr.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_DA_L1iJWNNM09xFPbqTpoA_iQjdcvEf';
  static const String functionsBaseUrl = '$supabaseUrl/functions/v1';

  bool _initialized = false;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _initialized = true;
  }
}
