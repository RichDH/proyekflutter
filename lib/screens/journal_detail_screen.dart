import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.location),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  DateFormat.yMMMMEEEEd('id_ID').format(entry.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Dicatat pada pukul ${DateFormat.Hm('id_ID').format(entry.date)}',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Cuaca',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.thermostat,
              label: 'Suhu',
              value: '${entry.temperature.toStringAsFixed(1)} °C',
            ),
            _buildDetailRow(
              icon: Icons.cloud,
              label: 'Kondisi',
              value: entry.weatherCondition,
            ),
            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Lokasi',
              value: entry.location,
            ),
            const SizedBox(height: 24),

            Text(
              'Catatan Jurnal Anda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                entry.notes,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}