import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static late SupabaseClient _client;
  static late SupabaseClient _adminClient;

  static SupabaseClient get client => _client;
  static SupabaseClient get adminClient => _adminClient;

  static Future<void> initialize() async {
    try {
      print('Starting Supabase initialization...');
      await dotenv.load(fileName: '.env');

      // Validate environment variables
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      final serviceKey = dotenv.env['SUPABASE_SERVICE_KEY'];
      final smtpEmail = dotenv.env['SMTP_EMAIL'];
      final smtpPassword = dotenv.env['SMTP_PASSWORD'];

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception('SUPABASE_URL is missing or empty in .env');
      }
      if (anonKey == null || anonKey.isEmpty) {
        throw Exception('SUPABASE_ANON_KEY is missing or empty in .env');
      }
      if (serviceKey == null || serviceKey.isEmpty) {
        throw Exception('SUPABASE_SERVICE_KEY is missing or empty in .env');
      }

      // Email configuration is optional but warn if missing
      if (smtpEmail == null ||
          smtpEmail.isEmpty ||
          smtpPassword == null ||
          smtpPassword.isEmpty) {
        print(
            'Warning: Email configuration is missing. Email features will be disabled.');
      }

      print('Environment variables validated');

      // Initialize user client
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
      print('User client initialized');

      // Initialize admin client
      _adminClient = SupabaseClient(
        supabaseUrl,
        serviceKey,
      );
      print('Admin client initialized');
    } catch (e) {
      print('Supabase initialization failed: $e');
      throw Exception('Failed to initialize Supabase: $e');
    }
  }
}
