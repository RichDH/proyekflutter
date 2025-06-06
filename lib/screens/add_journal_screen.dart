import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';
import '../provider/journal_provider.dart';
import '../services/auth_service.dart';
import '../model/journal_entry.dart';

class AddJournalScreen extends StatefulWidget {
  @override
  _AddJournalScreenState createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
    });
  }

  void _saveJournal(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final currentWether = weatherProvider.weather;

    if (currentUser != null && currentWether != null) {
      final newEntry = JournalEntry(
        location: currentWether.cityName,
        weatherCondition: currentWether.condition,
        temperature: currentWether.temperature,
        notes: _notesController.text,
        date: DateTime.now(),
        userId: currentUser.uid,
      );
      journalProvider.addEntry(newEntry);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan, data cuaca atau user tidak ditemukan.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Jurnal Baru'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveJournal(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            switch (weatherProvider.state) {
              case WeatherState.loading:
                return Center(child: CircularProgressIndicator());
              case WeatherState.error:
                return Center(child: Text('Error: ${weatherProvider.errorMessage}'));
              case WeatherState.loaded:
                return SingleChildScrollView( // Agar tidak overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cuaca Saat Ini:', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Text('Lokasi: ${weatherProvider.weather!.cityName}'),
                      Text('Suhu: ${weatherProvider.weather!.temperature.toStringAsFixed(1)}°C'),
                      Text('Kondisi: ${weatherProvider.weather!.condition}'),
                      SizedBox(height: 24),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Catatan Jurnal Hari Ini',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ),
                );
              default:
                return Center(child: Text('Tekan refresh untuk mengambil data cuaca.'));
            }
          },
        ),
      ),
    );
  }
}