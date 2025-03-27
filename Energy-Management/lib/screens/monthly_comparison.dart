import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/meter_reading.dart'; // Adjust the import path if needed

class MonthlyComparison extends StatefulWidget {
  const MonthlyComparison({super.key});

  @override
  State<MonthlyComparison> createState() => _MonthlyComparisonState();
}

class _MonthlyComparisonState extends State<MonthlyComparison> {
  final _dio = Dio();
  String selectedMonth = 'January';
  Map<String, List<MeterReading>> hostelReadings = {};

  @override
  void initState() {
    super.initState();
    _fetchMeterReadings();
  }

  Future<void> _fetchMeterReadings() async {
    const url =
        'https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json'; // Replace with your Firebase URL
    try {
      final response = await _dio.get(url);
      final extractedData = response.data as Map<String, dynamic>?;

      if (extractedData == null) {
        return;
      }

      List<MeterReading> loadedData =[];
      extractedData.forEach((key, value) {
        final meterReading = MeterReading.fromJson(value);
        loadedData.add(meterReading);
      });

      hostelReadings = {};
      for (var reading in loadedData) {
        if (!hostelReadings.containsKey(reading.hostel)) {
          hostelReadings[reading.hostel] =[];
        }
        hostelReadings[reading.hostel]!.add(reading);
      }

      setState(() {});
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Map<String, double> _calculateMonthlyTotals(String month) {
    Map<String, double> hostelTotals = {};
    int monthNumber = _getMonthNumber(month);

    hostelReadings.forEach((hostel, readings) {
      if (readings.isEmpty) return;
      double total = 0;
      for (var entry in readings) {
        if (entry.date.month == monthNumber) {
          total += entry.reading;
        }
      }
      hostelTotals[hostel] = total;
    });
    return hostelTotals;
  }

  int _getMonthNumber(String month) {
    switch (month) {
      case 'January':
        return 1;
      case 'February':
        return 2;
      case 'March':
        return 3;
      case 'April':
        return 4;
      case 'May':
        return 5;
      case 'June':
        return 6;
      case 'July':
        return 7;
      case 'August':
        return 8;
      case 'September':
        return 9;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> monthlyTotals = _calculateMonthlyTotals(selectedMonth);
    List<BarChartGroupData> barGroups =[];
    List<Color> hostelColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    int colorIndex = 0;

    monthlyTotals.forEach((hostel, total) {
      barGroups.add(
        BarChartGroupData(
          x: hostel.hashCode,
          barRods: [
            BarChartRodData(
              toY: total,
              color: hostelColors[colorIndex % hostelColors.length],
              width: 16,
            ),
          ],
        ),
      );
      colorIndex++;
    });

    double maxY = 12000; // Fixed maxY value

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Hostel Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              items: const [
                DropdownMenuItem(value: 'January', child: Text('January')),
                DropdownMenuItem(value: 'February', child: Text('February')),
                DropdownMenuItem(value: 'March', child: Text('March')),
                DropdownMenuItem(value: 'April', child: Text('April')),
                DropdownMenuItem(value: 'May', child: Text('May')),
                DropdownMenuItem(value: 'June', child: Text('June')),
                DropdownMenuItem(value: 'July', child: Text('July')),
                DropdownMenuItem(value: 'August', child: Text('August')),
                DropdownMenuItem(value: 'September', child: Text('September')),
                DropdownMenuItem(value: 'October', child: Text('October')),
                DropdownMenuItem(value: 'November', child: Text('November')),
                DropdownMenuItem(value: 'December', child: Text('December')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String hostel = monthlyTotals.keys.firstWhere(
                              (key) => key.hashCode == value.toInt(),
                              orElse: () => '');
                          return Text(hostel);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 5, // Adjust interval to fit Y values
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8.0),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String hostel = monthlyTotals.keys.firstWhere(
                            (key) => key.hashCode == group.x,
                            orElse: () => '');
                        return BarTooltipItem(
                          '$hostel\n${rod.toY.toStringAsFixed(2)} kWh',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  maxY: maxY,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: monthlyTotals.keys.map((hostel) {
                int index = monthlyTotals.keys.toList().indexOf(hostel) %
                    hostelColors.length;
                return Chip(
                  backgroundColor: hostelColors[index],
                  label: Text(hostel),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}