import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String geminiApiKey = "AIzaSyBRp848rmMGd3zErs5x6-e7Jzu18JIvZn0"; // Replace with your Gemini API Key

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  _AIRecommendationsScreenState createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  String selectedHostel = 'Hostel A';
  String connectionStatus = "Checking...";
  String aiResponse = "Fetching recommendations...";
  String aiResponse2 = "Fetching comparisons...";
  Map<String, dynamic>? energyData;
  Map<String, dynamic>? meterData; // Added meter data
  bool hasConnection = true;

  @override
  void initState() {
    super.initState();
    fetchDatabaseData();
  }

  Future<void> fetchDatabaseData() async {
    try {
      final energyResponse = await http.get(Uri.parse(
          "https://ecowise-fcc75-default-rtdb.firebaseio.com/energy-data.json"));
      final meterResponse = await http.get(Uri.parse(
          "https://ecowise2-f3ef6-default-rtdb.firebaseio.com/meterReadings.json"));

      if (energyResponse.statusCode == 200 && meterResponse.statusCode == 200) {
        setState(() {
          connectionStatus = "Connected";
          energyData = jsonDecode(energyResponse.body);
          meterData = jsonDecode(meterResponse.body); // Parse meter data
          hasConnection = true;
        });
        fetchAiRecommendations(energyData);
        fetchAiRecommendations2(energyData, meterData); // Pass both data sets
      } else {
        setState(() {
          connectionStatus = "Check your connection!";
          aiResponse = "Failed to fetch data.";
          aiResponse2 = "Failed to fetch data.";
          hasConnection = false;
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = "Check your connection!";
        aiResponse = "Error fetching data: ${e.toString()}";
        aiResponse2 = "Error fetching data: ${e.toString()}";
        hasConnection = false;
      });
    }
  }

  Future<void> fetchAiRecommendations(Map<String, dynamic>? jsonData) async {
    if (jsonData == null) {
      setState(() {
        aiResponse = "No data available.";
      });
      return;
    }

    String dataString = "";
    jsonData.forEach((key, value) {
      dataString += "$key: $value, ";
    });
    if (dataString.isNotEmpty) {
      dataString = dataString.substring(0, dataString.length - 2);
    }

    final String prompt = """
    How do I save energy for $selectedHostel? Provide 6 points with a brief explanation (three to four lines) with a space between each point. Here is the data from the hostel: $dataString""";

    print("Sending prompt to Gemini API: $prompt");

    try {
      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          aiResponse =
              decoded["candidates"][0]["content"]["parts"][0]["text"].toString();
        });
      } else {
        setState(() {
          aiResponse = "Failed to fetch AI recommendations. Try again later.";
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        aiResponse = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> fetchAiRecommendations2(
      Map<String, dynamic>? energyData, Map<String, dynamic>? meterData) async {
    if (energyData == null || meterData == null) {
      setState(() {
        aiResponse2 = "No data available for comparison.";
      });
      return;
    }

    String energyString = "";
    energyData.forEach((key, value) {
      energyString += "$key: $value, ";
    });
    if (energyString.isNotEmpty) {
      energyString = energyString.substring(0, energyString.length - 2);
    }

    String meterString = "";
    meterData.forEach((key, value) {
      meterString += "$key: $value, ";
    });
    if (meterString.isNotEmpty) {
      meterString = meterString.substring(0, meterString.length - 2);
    }

    final String prompt = """
    Compare energy consumption for $selectedHostel with other hostels, compare lighting, heating and charging.also deterimine which hostel cosumes the most energy by adding 
    the meter readings for each hostel, dont show the calculations just provide the final values. Provide 6 points with a brief explanation (three to four lines) with a space 
    between the cmparison points. Here is the device energy data from the hostel: $energyString, and here is meter data: $meterString""";

    print("Sending prompt to Gemini API 2: $prompt");

    try {
      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print("Response Status Code 2: ${response.statusCode}");
      print("Response Body 2: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          aiResponse2 =
              decoded["candidates"][0]["content"]["parts"][0]["text"].toString();
        });
      } else {
        setState(() {
          aiResponse2 = "Failed to fetch AI comparisons. Try again later.";
        });
      }
    } catch (e) {
      print("Error 2: $e");
      setState(() {
        aiResponse2 = "Error 2: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "AI Recommendations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Image.asset(
              'assets/ic_launcher.png',
              width: 30,
              height: 30,
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "To save energy for:",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedHostel,
                  dropdownColor: Colors.grey[800],
                  style: TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedHostel = newValue!;
                      aiResponse = "Fetching recommendations...";
                      aiResponse2 = "Fetching comparisons...";
                    });
                    fetchAiRecommendations(energyData);
                    fetchAiRecommendations2(energyData, meterData); // Pass both data sets
                  },
                  items: <String>['Hostel A', 'Hostel B', 'Hostel C', 'Hostel D'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              connectionStatus,
              style: TextStyle(
                fontSize: 16,
                color: connectionStatus == "Connected"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.grey[800],
                child: Container(
                  height: 360,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: hasConnection
                        ? RichText(
                            text: _buildRichText(aiResponse),
                            textAlign: TextAlign.left,
                          )
                        : const Text(
                            "Couldn't fetch Data",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1),
            const Center(
              child: Text(
                "Hostel Comparison",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.grey[800],
                child: Container(
                  height: 360,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: hasConnection
                        ? RichText(
                            text: _buildRichText2(aiResponse2),
                            textAlign: TextAlign.left,
                          )
                        : const Text(
                            "Couldn't fetch Data",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildRichText(String text) {
    final RegExp boldRegex = RegExp(r'\*(.*?)\*');
    final List<TextSpan> textSpans = [];
    int currentIndex = 0;

    boldRegex.allMatches(text).forEach((match) {
      if (match.start > currentIndex) {
        textSpans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
      }
      textSpans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ));
      currentIndex = match.end;
    });

    if (currentIndex < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(color: Colors.white, fontSize: 16),
      ));
    }
    return TextSpan(children: textSpans);
  }

  TextSpan _buildRichText2(String text) {
    final RegExp boldRegex = RegExp(r'\*(.*?)\*');
    final List<TextSpan> textSpans = [];
    int currentIndex = 0;

    boldRegex.allMatches(text).forEach((match) {
      if (match.start > currentIndex) {
        textSpans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
      }
      textSpans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ));
      currentIndex = match.end;
    });

    if (currentIndex < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(color: Colors.white, fontSize: 16),
      ));
    }
    return TextSpan(children: textSpans);
  }
}
                  