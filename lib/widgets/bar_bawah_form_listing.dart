import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'bar_bawah_kaca.dart';
import 'primary_button.dart';

// Bar dua tombol di bawah form upload penjual.
// Langkah 2: "Simpan draft" + "Lanjut ke harga".
// Langkah 3: "Atur manual" + "Terbitkan".
class BarBawahFormListing extends StatelessWidget {
  final bool tahapForm;
  final bool sedangMemproses;
  final VoidCallback onTombolKiri;
  final VoidCallback onTombolKanan;

  const BarBawahFormListing({
    super.key,
    required this.tahapForm,
    required this.sedangMemproses,
    required this.onTombolKiri,
    required this.onTombolKanan,
  });

  @override
  Widget build(BuildContext context) {
    return BarBawahKaca(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
              ),
              onPressed: sedangMemproses ? null : onTombolKiri,
              child: Text(
                tahapForm ? 'Simpan draft' : 'Atur manual',
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            flex: 2,
            child: tahapForm
                ? PrimaryButton(
                    teks: 'Lanjut ke harga',
                    sedangMemuat: sedangMemproses,
                    onPressed: onTombolKanan,
                  )
                : PrimaryButton(
                    teks: 'Terbitkan',
                    ikon: Icons.check,
                    onPressed: onTombolKanan,
                  ),
          ),
        ],
      ),
    );
  }
}
