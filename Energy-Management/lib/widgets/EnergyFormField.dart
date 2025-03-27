import 'package:flutter/material.dart';

class EnergyFormField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String)? validator;
  final bool? isReadOnly;
  final void Function()? onTap;
  final void Function(String?)? onSaved;

  const EnergyFormField(
      {super.key,
      required this.hintText,
      this.keyboardType,
      this.controller,
      this.validator,
      this.isReadOnly,
      this.onSaved,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      onSaved: onSaved,
      readOnly: isReadOnly ?? false,
      controller: controller,
      keyboardType: keyboardType,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
      decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          )),
    );
  }
}
