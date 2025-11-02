import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isLoggedIn = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthService(this._prefs) {
    checkLoginStatus();
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final session = _supabase.auth.currentSession;
    _isLoggedIn = session != null;
    notifyListeners();
  }
  
  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _isLoggedIn = true;
        
        final user = response.user!;
        final fullName = user.userMetadata?['full_name'] as String?;
        final avatarUrl = user.userMetadata?['avatar_url'] as String?;

        await _prefs.setString('user_name', fullName ?? user.email ?? 'User'); 
        if (avatarUrl != null) {
          await _prefs.setString('avatar_url', avatarUrl);
        }
        
        notifyListeners(); 
        return null; 
      }
      return "User tidak ditemukan.";
    } catch (e) {
      print("Error login Supabase: $e");
      return e.toString();
    }
  }
  
  Future<String?> signUp(String fullName, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'avatar_url': null, 
        }, 
      );
      
      if (response.user != null) {
        return null;
      }
      return "Gagal membuat user.";
    } catch (e) {
      print("Error sign up Supabase: $e");
      return e.toString(); 
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _prefs.clear(); 
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }

  Future<String?> updateUserProfile(String avatarUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return "User not found";

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'avatar_url': avatarUrl,
            'full_name': user.userMetadata?['full_name'],
          },
        ),
      );
      
      await _prefs.setString('avatar_url', avatarUrl);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void signOut(BuildContext context) {}
}