import 'package:expense_tracker/models/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final supabase = Supabase.instance.client;

  //get expenses from db
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final user = supabase.auth.currentUser;

    final response = await Supabase.instance.client
        .from('expenses')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  //delete an expense
  deleteExpense(Expense expense) async {
    final response = await supabase
        .from('expenses')
        .delete()
        .eq('id', expense.id);
    print(response);
  }
}
