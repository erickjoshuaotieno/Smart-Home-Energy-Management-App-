// Portion 1: Imports and State Initialization

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/meter_reading.dart';
import 'monthly_energy_usage_graph.dart';
import 'weekly_comparison.dart';
import 'monthly_comparison.dart';

class EnergyUsageGraph extends StatefulWidget {
  const EnergyUsageGraph({super.key});

  @override
  State<EnergyUsageGraph> createState() => _EnergyUsageGraphState();
}

class _EnergyUsageGraphState extends State<EnergyUsageGraph> {
  final _dio = Dio();
  String? selectedHostel;
  String selectedGraphType = 'Weekly';
  String selectedWeek = 'Week 1';

  @override
  void initState() {
    super.initState();
    selectedHostel = 'HOSTEL A';
  }

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
        if (selectedHostel == null || meterReading.hostel == selectedHostel) {
          loadedData.add(meterReading);
        }
      });
      return loadedData;
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }
  // Portion 2: Weekly Data Calculation and Comparison Popups

  List<FlSpot> _calculateWeeklySpots(List<MeterReading> meterReadings) {
    if (meterReadings.isEmpty) {
      return [];
    }

    Map<int, double> dailyTotals = {
      0: 0.0,
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0
    };

    int weekNumber = int.parse(selectedWeek.split(' ')[1]);
    DateTime firstEntryDate = meterReadings
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

    for (var entry in meterReadings) {
      if (entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        int dayIndex = entry.date.weekday % 7;
        dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0.0) + entry.reading;
      }
    }

    return dailyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  void _showHostelComparisonPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hostel Comparisons'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showWeeklyComparisonPopup(context);
                },
                child: const Text('Weekly Comparison'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showMonthlyComparisonPopup(context);
                },
                child: const Text('Monthly Comparison'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeeklyComparisonPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(''),
          ),
          body: const WeeklyComparison(),
        );
      },
    );
  }

  void _showMonthlyComparisonPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(''),
          ),
          body: const MonthlyComparison(),
        );
      },
    );
  }
  // Portion 3: Building the UI with Dropdowns and Graph Display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumption Graph'),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () => _showHostelComparisonPopup(context),
              child: const Text("Hostel Comparison"),
            ),
          ),
        ],
      ),
      body: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedGraphType,
                      items: const [
                        DropdownMenuItem(
                            value: 'Weekly',
                            child: Text('Weekly Consumption (kwh)')),
                        DropdownMenuItem(
                            value: 'Monthly',
                            child: Text('Monthly Consumption (kwh)')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGraphType = newValue!;
                        });
                      },
                    ),
                    if (selectedGraphType == 'Weekly')
                      DropdownButton<String>(
                        value: selectedWeek,
                        items: const [
                          DropdownMenuItem(
                              value: 'Week 1', child: Text('Week 1')),
                          DropdownMenuItem(
                              value: 'Week 2', child: Text('Week 2')),
                          DropdownMenuItem(
                              value: 'Week 3', child: Text('Week 3')),
                          DropdownMenuItem(
                              value: 'Week 4', child: Text('Week 4')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWeek = newValue!;
                          });
                        },
                      ),
                    DropdownButton<String>(
                      value: selectedHostel,
                      hint: const Text('Hostel'),
                      items: const [
                        DropdownMenuItem(
                            value: 'HOSTEL A', child: Text('HOSTEL A')),
                        DropdownMenuItem(
                            value: 'HOSTEL B', child: Text('HOSTEL B')),
                        DropdownMenuItem(
                            value: 'HOSTEL C', child: Text('HOSTEL C')),
                        DropdownMenuItem(
                            value: 'HOSTEL D', child: Text('HOSTEL D')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedHostel = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: selectedGraphType == 'Weekly'
                    ? (selectedHostel != null)
                        ? FutureBuilder<List<MeterReading>>(
                            future: _fetchMeterReadings(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No meter readings available.'));
                              }

                              final weeklySpots =
                                  _calculateWeeklySpots(snapshot.data!);

                              if (weeklySpots.isEmpty) {
                                return const Center(
                                    child:
                                        Text("No data for the selected week."));
                              }

                              return LineChart(
                                LineChartData(
                                  gridData: const FlGridData(
                                      show: true, drawVerticalLine: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return const Text('Sun');
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
                                        interval: 250,
                                        getTitlesWidget: (value, meta) {
                                          return Text('${value.toInt()}');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: 1000,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: weeklySpots,
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                          show: true,
                                          color:
                                              Colors.blue.withOpacity(0.2)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('Select a hostel and week.'))
                    : MonthlyEnergyUsageGraph(selectedHostel: selectedHostel!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}