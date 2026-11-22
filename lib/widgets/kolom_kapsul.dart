import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kolom isian kapsul dengan label di atasnya (PillTextField Recovera lama).
// Dipakai di Login dan Register.
class KolomKapsul extends StatelessWidget {
  final String label;
  final String? petunjuk;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool sembunyikanTeks;
  final Widget? ikonKanan;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  const KolomKapsul({
    super.key,
    required this.label,
    this.petunjuk,
    this.controller,
    this.keyboardType,
    this.sembunyikanTeks = false,
    this.ikonKanan,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.jarakTepi, bottom: AppTheme.jarakMini),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontLabelInput,
              fontWeight: FontWeight.w600,
              color: AppTheme.warnaLabelInput,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: sembunyikanTeks,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          validator: validator,
          maxLength: maxLength,
          style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w500, color: AppTheme.warnaNavy),
          decoration: InputDecoration(hintText: petunjuk, suffixIcon: ikonKanan, counterText: ''),
        ),
      ],
    );
  }
}
