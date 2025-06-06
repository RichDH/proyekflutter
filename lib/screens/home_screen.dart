import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/journal_entry.dart';
import '../provider/journal_provider.dart';
import '../services/auth_service.dart';
import 'add_journal_screen.dart';
import 'journal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<JournalProvider>(context, listen: false)
            .fetchEntries(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weather Journal'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final bool? shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authService.signOut();
              }
            },
          )
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          if (journalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (journalProvider.entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Belum ada jurnal tersimpan.\nTekan tombol + untuk membuat jurnal pertamamu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: journalProvider.entries.length,
            itemBuilder: (ctx, index) {
              final JournalEntry entry = journalProvider.entries[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      '${entry.temperature.toStringAsFixed(0)}°',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.location,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat('d MMM yyyy').format(entry.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JournalDetailScreen(entry: entry),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddJournalScreen(),
            ),
          );
        },
        tooltip: 'Tambah Jurnal',
        child: const Icon(Icons.add),
      ),
    );
  }
}