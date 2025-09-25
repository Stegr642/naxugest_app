import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseClient(
    dotenv.env['SUPABASE_URL'] ?? '',
    dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  /// Login avec email + mot de passe
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// Logout
  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Récupérer l’utilisateur connecté
  static User? get currentUser => _client.auth.currentUser;

  /// Vérifier si un utilisateur est connecté
  static bool get isLoggedIn => _client.auth.currentUser != null;

  /// Inscription (optionnel)
  static Future<bool> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }
}
