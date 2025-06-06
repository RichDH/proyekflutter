class JournalEntry {
  final int? id;
  final String location;
  final String weatherCondition;
  final double temperature;
  final String notes;
  final DateTime date;
  final String userId;

  JournalEntry({
    this.id,
    required this.location,
    required this.weatherCondition,
    required this.temperature,
    required this.notes,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'weatherCondition': weatherCondition,
      'temperature': temperature,
      'notes': notes,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}