import 'package:energy_management/models/form_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class EnergyManagementProvider with ChangeNotifier {
  final _dio = Dio();
  List<FormModel> _energyDataList = [];
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleAppTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  List<FormModel> get energyDataList {
    return [..._energyDataList];
  }

  Future<void> saveEnergyData(FormModel energyData) async {
    const url =
        'https://ecowise-fcc75-default-rtdb.firebaseio.com/energy-data.json';
    try {
      final response = await _dio.post(url,
          data: json.encode({
            'hostelName': energyData.hostelName,
            'applianceName': energyData.applianceName,
            'kwh': energyData.kwh,
            'dateFilled': energyData.dateFilled.toIso8601String()
          }));
      final newEnergyData = FormModel(
          id: response.data['name'],
          hostelName: energyData.hostelName,
          applianceName: energyData.applianceName,
          kwh: energyData.kwh,
          dateFilled: energyData.dateFilled);
      _energyDataList.add(newEnergyData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<FormModel>> getEnergyData({String? hostelFilter}) async {
    const baseUrl =
        'https://ecowise-fcc75-default-rtdb.firebaseio.com/energy-data.json';

    final url = hostelFilter != null
        ? '$baseUrl?orderBy="hostelName"&equalTo="$hostelFilter"'
        : baseUrl;
    try {
      final response = await _dio.get(url);
      final extractedData = response.data as Map<String, dynamic>;
      final List<FormModel> loadedData = [];
      extractedData.forEach((enId, enData) {
        loadedData.add(FormModel(
            id: enId,
            hostelName: enData['hostelName'],
            applianceName: enData['applianceName'],
            kwh: enData['kwh'],
            dateFilled: DateTime.parse(enData['dateFilled'])));
      });
      _energyDataList = loadedData;
      notifyListeners();
      return loadedData;
    } catch (error) {
      rethrow;
    }
  }
}
