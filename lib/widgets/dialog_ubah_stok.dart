import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Dialog "Ubah Stok / Harga Minimum" untuk listing aktif. Memegang dua
// TextEditingController sendiri (di-dispose saat ditutup). Simpan dengan isian
// benar -> ditutup dengan {'jumlah': int, 'hargaMinimum': double}; Batal = null.
class DialogUbahStok extends StatefulWidget {
  final ListingModel listing;

  const DialogUbahStok({super.key, required this.listing});

  @override
  State<DialogUbahStok> createState() => _DialogUbahStokState();
}

class _DialogUbahStokState extends State<DialogUbahStok> {
  late final TextEditingController jumlahController = TextEditingController(text: '${widget.listing.stok}');
  late final TextEditingController hargaMinimumController =
      TextEditingController(text: widget.listing.hargaMinimum.round().toString());
  String? _pesanGalat;

  @override
  void dispose() {
    jumlahController.dispose();
    hargaMinimumController.dispose();
    super.dispose();
  }

  void _simpan() {
    final int? jumlah = int.tryParse(jumlahController.text);
    final double? hargaMinimum = double.tryParse(hargaMinimumController.text);
    if (jumlah == null || jumlah < 0 || hargaMinimum == null || hargaMinimum <= 0) {
      setState(() => _pesanGalat = 'Isi stok dan harga minimum dengan angka yang benar');
      return;
    }
    Navigator.pop(context, <String, dynamic>{'jumlah': jumlah, 'hargaMinimum': hargaMinimum});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Stok / Harga Minimum'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: jumlahController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Stok (${widget.listing.satuan})'),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          TextField(
            controller: hargaMinimumController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Harga minimum (Rp)'),
          ),
          if (_pesanGalat != null) ...[
            const SizedBox(height: AppTheme.jarakKecil),
            Text(_pesanGalat!, style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaGalatTeks)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: _simpan, child: const Text('Simpan')),
      ],
    );
  }
}
