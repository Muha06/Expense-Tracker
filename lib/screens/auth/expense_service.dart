import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final supabase = Supabase.instance.client;

  //get expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final user = supabase.auth.currentUser;

    final response = await Supabase.instance.client
        .from('expenses')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
