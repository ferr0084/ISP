import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> initSupabase() async {
  try {
    await dotenv.load(fileName: "../.env");

    debugPrint('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
    debugPrint('SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']}');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    return true;
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    return false;
  }
}
