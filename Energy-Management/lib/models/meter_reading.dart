// models/meter_reading.dart
class MeterReading {
  final String hostel;
  final DateTime date;
  final double reading;

  MeterReading({
    required this.hostel,
    required this.date,
    required this.reading,
  });

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
      hostel: json['hostel'],
      date: DateTime.parse(json['date']),
      reading: double.parse(json['reading']),
    );
  }
}