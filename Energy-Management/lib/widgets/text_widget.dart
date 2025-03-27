import 'package:flutter/material.dart';

class EnergyReUsableTextWidget extends StatelessWidget {
  final String text;
  const EnergyReUsableTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    );
  }
}
