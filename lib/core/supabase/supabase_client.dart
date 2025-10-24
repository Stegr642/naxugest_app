import 'package:supabase_flutter/supabase_flutter.dart';

const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://ywuplidfweohvfwjtnmb.supabase.co',
);
const String _supabaseAnon = String.fromEnvironment(
  'SUPABASE_ANON',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3dXBsaWRmd2VvaHZmd2p0bm1iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NjQ1OTMsImV4cCI6MjA3NjU0MDU5M30.dcKY1XvvYOYAKEa-fUDT2ewp1x22n7Tmm3q7fPL9H4s',
);

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnon,
  );
}

/// Client global (schéma public)
SupabaseClient get supa => Supabase.instance.client;
