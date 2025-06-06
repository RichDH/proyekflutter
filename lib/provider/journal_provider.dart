import 'package:flutter/material.dart';
import '../model/journal_entry.dart';
import '../services/database_helper.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries(String userId) async {
    _isLoading = true;
    notifyListeners();
    _entries = await DatabaseHelper.instance.getEntries(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await DatabaseHelper.instance.create(entry);
    fetchEntries(entry.userId);
  }
}