import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DeviceUsage extends StatefulWidget {
  const DeviceUsage({super.key});

  @override
  State<DeviceUsage> createState() => _DeviceUsageState();
}

class _DeviceUsageState extends State<DeviceUsage> {
  String? selectedHostel;
  List<Map<String, dynamic>> energyData = [];
  List<Map<String, dynamic>> meterData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedDataType = 'Devices logged'; // Default to devices

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchMeterData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://ecowise-fcc75-default-rtdb.firebaseio.com/energy-data.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          energyData = data.values
              .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item))
              .toList();
          filterData();
        } else {
          errorMessage = 'No device data found.';
        }
      } else {
        errorMessage = 'Failed to load device data: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'An error occurred fetching device data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMeterData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          meterData = data.values
              .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item))
              .toList();
          filterData();
        } else {
          errorMessage = 'No meter data found.';
        }
      } else {
        errorMessage = 'Failed to load meter data: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'An error occurred fetching meter data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData() {
    if (selectedHostel == null || selectedHostel!.isEmpty) {
      filteredData = selectedDataType == 'Devices logged'
          ? List.from(energyData)
          : List.from(meterData);
    } else {
      filteredData = selectedDataType == 'Devices logged'
          ? energyData
              .where((item) => item['hostelName'] == selectedHostel)
              .toList()
          : meterData
              .where((item) => item['hostel'] == selectedHostel)
              .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: selectedDataType,
          items: <String>['Devices logged', 'Meter readings']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedDataType = newValue!;
              filterData();
            });
          },
          underline: Container(),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/ic_launcher.png',
              width: 34,
              height: 34,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: selectedHostel,
                            hint: const Text('Select Hostel'),
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
                                filterData();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: selectedDataType == 'Devices logged'
                                  ? const [
                                      DataColumn(label: Text('Hostel')),
                                      DataColumn(label: Text('Device')),
                                      DataColumn(label: Text('Rating (kwh)')),
                                      DataColumn(label: Text('Date')),
                                    ]
                                  : const [
                                      DataColumn(label: Text('Hostel')),
                                      DataColumn(label: Text('Meter Reading')),
                                      DataColumn(label: Text('Date')),
                                    ],
                              rows: [
                                ...filteredData.map((item) {
                                  return DataRow(
                                      cells: selectedDataType == 'Devices logged'
                                          ? [
                                              DataCell(
                                                  Text(item['hostelName'] ?? '')),
                                              DataCell(
                                                  Text(item['applianceName'] ?? '')),
                                              DataCell(Text(
                                                  item['kwh'].toString() ?? '')),
                                              DataCell(
                                                  Text(item['dateFilled'] ?? '')),
                                            ]
                                          : [
                                              DataCell(Text(item['hostel'] ?? '')),
                                              DataCell(
                                                  Text(item['reading'] ?? '')),
                                              DataCell(Text(item['date'] ?? '')),
                                            ]);
                                }),
                                if (selectedDataType == 'Meter readings')
                                  ..._buildMeterTotals(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (selectedDataType == 'Devices logged')
                        Center(
                          child: SizedBox(
                            height: 120,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildConsumptionCard('Lighting'),
                                _buildConsumptionCard('Heating'),
                                _buildConsumptionCard('Charging'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  List<DataRow> _buildMeterTotals() {
    if (filteredData.isEmpty) {
      return []; // Return an empty list if there's no data
    }

    // 1. Sort the data by date
    filteredData.sort((a, b) => a['date'].compareTo(b['date']));

    Map<String, double> hostelTotals = {};
    Map<String, List<Map<String, dynamic>>> weeklyData = {};
    int weekNumber = 1;
    DateTime? currentWeekStart = filteredData.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(filteredData.first['date'])
        : null;

    for (var item in filteredData) {
      DateTime itemDate = DateFormat('yyyy-MM-dd').parse(item['date']);

      if (currentWeekStart == null ||
          itemDate.difference(currentWeekStart).inDays >= 7) {
        currentWeekStart = itemDate;
        weekNumber++;
      }

      String weekKey = 'Week $weekNumber';

      weeklyData.update(
        weekKey,
            (value) => [...value, item],
        ifAbsent: () => [item],
      );

      hostelTotals.update(
        item['hostel'],
            (value) => value + double.parse(item['reading']),
        ifAbsent: () => double.parse(item['reading']),
      );
    }

    List<DataRow> rows =[];

    // Add weekly totals
    for (var week in weeklyData.entries) {
      double weekTotal = week.value.fold<double>(
              0, (sum, item) => sum + double.parse(item['reading']));
      rows.add(DataRow(cells: [
        DataCell(Text(week.key)),
        DataCell(Text(weekTotal.toStringAsFixed(2))),
        const DataCell(Text('')),
      ]));
    }

    // Add overall totals
    rows.addAll(hostelTotals.entries.map((entry) {
      return DataRow(cells: [
        DataCell(Text('${entry.key} Total')),
        DataCell(Text(entry.value.toStringAsFixed(2))),
        const DataCell(Text('')),
      ]);
    }).toList());

    return rows;
  }


  Widget _buildConsumptionCard(String category) {
    double totalConsumption = _calculateTotalConsumption(category);
    double percentage = _calculateConsumptionPercentage(category);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalConsumption.toStringAsFixed(2)} kWh',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalConsumption(String category) {
    double total = 0;
    for (var item in filteredData) {
      if (item['applianceName'] != null) {
        if (category == 'Lighting' &&
            item['applianceName'].toLowerCase().contains('lighting')) {
          total += item['kwh'];
        } else if (category == 'Heating' &&
            item['applianceName'].toLowerCase().contains('kettle')) {
          total += item['kwh'];
        } else if (category == 'Charging' &&
            (item['applianceName'].toLowerCase().contains('phone') ||
                item['applianceName'].toLowerCase().contains('laptop'))) {
          total += item['kwh'];
        }
      }
    }
    return total;
  }

  double _calculateConsumptionPercentage(String category) {
    double totalCategoryConsumption = _calculateTotalConsumption(category);
    double totalConsumption = filteredData.fold<double>(
        0, (sum, item) => sum + (item['kwh'] ?? 0));
    return totalConsumption > 0
        ? (totalCategoryConsumption / totalConsumption) * 100
        : 0;
  }
}