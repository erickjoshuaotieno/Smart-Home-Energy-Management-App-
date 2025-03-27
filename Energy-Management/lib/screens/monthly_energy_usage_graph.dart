// monthly_energy_usage_graph.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/meter_reading.dart';

class MonthlyEnergyUsageGraph extends StatefulWidget {
  final String selectedHostel;

  const MonthlyEnergyUsageGraph({super.key, required this.selectedHostel});

  @override
  State<MonthlyEnergyUsageGraph> createState() =>
      _MonthlyEnergyUsageGraphState();
}

class _MonthlyEnergyUsageGraphState extends State<MonthlyEnergyUsageGraph> {
  final _dio = Dio();

  Future<List<MeterReading>> _fetchMeterReadings() async {
    const url =
        'https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json';
    try {
      final response = await _dio.get(url);
      final extractedData = response.data as Map<String, dynamic>?;

      if (extractedData == null) {
        return [];
      }

      List<MeterReading> loadedData = [];
      extractedData.forEach((key, value) {
        final meterReading = MeterReading.fromJson(value);
        if (widget.selectedHostel == meterReading.hostel) {
          loadedData.add(meterReading);
        }
      });
      return loadedData;
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  List<FlSpot> _calculateMonthlySpots(List<MeterReading> meterReadings) {
    Map<int, double> monthlyTotals = {};

    for (var entry in meterReadings) {
      int month = entry.date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + entry.reading;
    }

    return monthlyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MeterReading>>(
      future: _fetchMeterReadings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No meter readings available.'));
        }

        final monthlySpots = _calculateMonthlySpots(snapshot.data!);

        // Find the maximum Y value for dynamic scaling
        double maxY = 30000; //Set max Y to 30000
        if (monthlySpots.isNotEmpty) {
          double maxDataY =
              monthlySpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
          if (maxDataY > maxY) {
            maxY = maxDataY;
          }
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: true),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 1:
                        return const Text('Jan');
                      case 2:
                        return const Text('Feb');
                      case 3:
                        return const Text('Mar');
                      case 4:
                        return const Text('Apr');
                      case 5:
                        return const Text('May');
                      case 6:
                        return const Text('Jun');
                      case 7:
                        return const Text('Jul');
                      case 8:
                        return const Text('Aug');
                      case 9:
                        return const Text('Sep');
                      case 10:
                        return const Text('Oct');
                      case 11:
                        return const Text('Nov');
                      case 12:
                        return const Text('Dec');
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 2500, //adjust interval to 5000
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
                show: true, border: Border.all(color: Colors.grey.shade300)),
            minX: 1,
            maxX: 12,
            minY: 0,
            maxY: 10000, // Use the dynamically calculated maxY
            lineBarsData: [
              LineChartBarData(
                spots: monthlySpots,
                isCurved: true,
                color: Colors.green,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData:
                    BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
              ),
            ],
          ),
        );
      },
    );
  }
}