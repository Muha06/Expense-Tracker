import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  //sign in
  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  //sign up
  Future<AuthResponse> signupWithEmailAndPassword(
    String email,
    String pword,
    String fname,
  ) async {
    final response = await _supabase.auth.signUp(email: email, password: pword);

    final user = response.user;

    if (user != null) {
      //upload additional user info
      try {
        await _supabase.from('profiles').insert({
          'user_id': user.id,
          'full_name': fname,
          'email': user.email,
        });
      } catch (e) {
        print('Insert error: $e');
      }
    }
    return response;
  }

  //sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //fetch user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return response;
  }

  //update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
  }) async {
    await _supabase
        .from('profiles')
        .update({
          if (fullName != null) 'full_name': fullName,
        })
        .eq('user_id', userId);
  }


  //get user email
  String? getUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
