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
  // Method ini dipanggil sekali saat widget pertama kali dibuat.
  // Kita gunakan untuk memuat data jurnal dari database.
  @override
  void initState() {
    super.initState();
    // Kita gunakan addPostFrameCallback untuk memastikan 'context' sudah siap digunakan.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil user ID yang sedang login
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        // Panggil provider untuk mengambil data jurnal berdasarkan user ID
        // listen: false karena kita hanya perlu memanggil method, tidak perlu me-rebuild widget ini.
        Provider.of<JournalProvider>(context, listen: false)
            .fetchEntries(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil auth service untuk fungsi logout
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
              // Tampilkan dialog konfirmasi sebelum logout
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
        // Consumer akan otomatis me-rebuild widget di dalam builder-nya
        // setiap kali journalProvider.notifyListeners() dipanggil.
        builder: (context, journalProvider, child) {
          // 1. Tampilkan loading indicator jika data sedang diambil
          if (journalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Tampilkan pesan jika tidak ada entri jurnal
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

          // 3. Tampilkan daftar jurnal jika data sudah ada
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
                    maxLines: 2, // Batasi catatan hingga 2 baris
                    overflow: TextOverflow.ellipsis, // Tampilkan '...' jika lebih
                  ),
                  trailing: Text(
                    // Format tanggal menggunakan package intl
                    DateFormat('d MMM yyyy').format(entry.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // Navigasi ke halaman detail saat item di-tap
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
          // Navigasi ke halaman untuk menambah jurnal baru
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