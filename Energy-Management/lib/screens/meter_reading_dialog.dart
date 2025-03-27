import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class MeterReadingDialog extends StatefulWidget {
  const MeterReadingDialog({super.key});

  @override
  _MeterReadingDialogState createState() => _MeterReadingDialogState();
}

class _MeterReadingDialogState extends State<MeterReadingDialog> {
  String? selectedHostel;
  DateTime selectedDate = DateTime.now();
  TextEditingController meterReadingController = TextEditingController();
  final _dio = Dio();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Meter Reading'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: DropdownButton<String>(
                value: selectedHostel,
                hint: const Text('Select Hostel'),
                items: const [
                  DropdownMenuItem(value: 'HOSTEL A', child: Text('HOSTEL A')),
                  DropdownMenuItem(value: 'HOSTEL B', child: Text('HOSTEL B')),
                  DropdownMenuItem(value: 'HOSTEL C', child: Text('HOSTEL C')),
                  DropdownMenuItem(value: 'HOSTEL D', child: Text('HOSTEL D')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedHostel = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextField(
                controller: meterReadingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Meter Reading'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Submit'),
          onPressed: () async {
            if (selectedHostel != null &&
                meterReadingController.text.isNotEmpty) {
              const url =
                  'https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json';

              try {
                final response = await _dio.post(url,
                    data: json.encode({
                      'hostel': selectedHostel,
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                      'reading': meterReadingController.text,
                    }));
                print('Firebase Response: ${response.data}');

                Navigator.of(context).pop();
              } catch (error) {
                print('Error submitting to Firebase: $error');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Failed to submit data.")));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please fill all fields")));
            }
          },
        ),
      ],
    );
  }
}