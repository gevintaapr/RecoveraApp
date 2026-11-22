import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Dropdown kapsul dengan label di atasnya (_RoleDropdown Recovera lama).
// pilihan: nilai yang dikirim ke backend -> label yang tampil.
class PilihanKapsul extends StatelessWidget {
  final String label;
  final String nilai;
  final Map<String, String> pilihan;
  final ValueChanged<String?> onChanged;

  const PilihanKapsul({
    super.key,
    required this.label,
    required this.nilai,
    required this.pilihan,
    required this.onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: nilai,
          isExpanded: true,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.warnaTeksRedup),
          style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w500, color: AppTheme.warnaNavy),
          items: pilihan.entries
              .map((entri) => DropdownMenuItem<String>(
                    value: entri.key,
                    child: Text(entri.value, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
