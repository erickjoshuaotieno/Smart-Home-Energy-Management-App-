import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/meter_reading.dart';

class WeeklyComparison extends StatefulWidget {
  const WeeklyComparison({super.key});

  @override
  State<WeeklyComparison> createState() => _WeeklyComparisonState();
}

class _WeeklyComparisonState extends State<WeeklyComparison> {
  final _dio = Dio();
  String selectedWeek = 'Week 1';
  Map<String, List<MeterReading>> hostelReadings = {};

  @override
  void initState() {
    super.initState();
    _fetchMeterReadings();
  }

  Future<void> _fetchMeterReadings() async {
    const url =
        'https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json';
    try {
      final response = await _dio.get(url);
      final extractedData = response.data as Map<String, dynamic>?;

      if (extractedData == null) {
        return;
      }

      List<MeterReading> loadedData = [];
      extractedData.forEach((key, value) {
        final meterReading = MeterReading.fromJson(value);
        loadedData.add(meterReading);
      });

      hostelReadings = {};
      for (var reading in loadedData) {
        if (!hostelReadings.containsKey(reading.hostel)) {
          hostelReadings[reading.hostel] = [];
        }
        hostelReadings[reading.hostel]!.add(reading);
      }

      setState(() {});
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Map<String, Map<int, double>> _calculateWeeklyDayTotals(String week) {
    Map<String, Map<int, double>> hostelDayTotals = {};
    int weekNumber = int.parse(week.split(' ')[1]);

    hostelReadings.forEach((hostel, readings) {
      if (readings.isEmpty) return;
      DateTime firstEntryDate = readings
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      DateTime firstDayOfMonth =
          DateTime(firstEntryDate.year, firstEntryDate.month, 1);
      DateTime firstMondayOfMonth = firstDayOfMonth.weekday == DateTime.monday
          ? firstDayOfMonth
          : firstDayOfMonth.add(
              Duration(days: (DateTime.monday - firstDayOfMonth.weekday) % 7));
      DateTime startOfWeek =
          firstMondayOfMonth.add(Duration(days: (weekNumber - 1) * 7));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

      Map<int, double> dayTotals = {
        0: 0.0, // Sunday
        1: 0.0, // Monday
        2: 0.0, // Tuesday
        3: 0.0, // Wednesday
        4: 0.0, // Thursday
        5: 0.0, // Friday
        6: 0.0, // Saturday
      };

      for (var entry in readings) {
        if (entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          int dayIndex = entry.date.weekday % 7;
          dayTotals[dayIndex] = (dayTotals[dayIndex] ?? 0.0) + entry.reading;
        }
      }
      hostelDayTotals[hostel] = dayTotals;
    });
    return hostelDayTotals;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<int, double>> weeklyDayTotals =
        _calculateWeeklyDayTotals(selectedWeek);
    List<BarChartGroupData> barGroups = [];
    List<Color> hostelColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    List<String> hostels = weeklyDayTotals.keys.toList();
    List<int> days = [1, 2, 3, 4, 5, 6, 0]; // Mon, Tue, Wed, Thu, Fri, Sat, Sun

    for (int day in days) {
      List<BarChartRodData> rods = [];
      for (int i = 0; i < hostels.length; i++) {
        String hostel = hostels[i];
        double total = weeklyDayTotals[hostel]![day] ?? 0.0;
        rods.add(
          BarChartRodData(
            toY: total,
            color: hostelColors[i % hostelColors.length],
            width: 16,
          ),
        );
      }
      barGroups.add(
        BarChartGroupData(
          x: day,
          barRods: rods,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Hostel Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedWeek,
              items: const [
                DropdownMenuItem(value: 'Week 1', child: Text('Week 1')),
                DropdownMenuItem(value: 'Week 2', child: Text('Week 2')),
                DropdownMenuItem(value: 'Week 3', child: Text('Week 3')),
                DropdownMenuItem(value: 'Week 4', child: Text('Week 4')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedWeek = newValue;
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
                          int dayIndex = value.toInt();
                          switch (dayIndex) {
                            case 1:
                              return const Text('Mon');
                            case 2:
                              return const Text('Tue');
                            case 3:
                              return const Text('Wed');
                            case 4:
                              return const Text('Thu');
                            case 5:
                              return const Text('Fri');
                            case 6:
                              return const Text('Sat');
                            case 0:
                              return const Text('Sun');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 500,
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
                        String hostel = hostels[rodIndex];
                        return BarTooltipItem(
                          '$hostel\n${rod.toY.toStringAsFixed(2)} kWh',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  maxY: 1000,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: hostels.map((hostel) {
                int index = hostels.indexOf(hostel) % hostelColors.length;
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