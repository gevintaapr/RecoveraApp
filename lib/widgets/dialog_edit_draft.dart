import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Dialog "Edit Isi Draf" di Detail Produk penjual. Memegang 5 TextEditingController
// sendiri (di-dispose saat dialog ditutup). Bila Simpan ditekan dan isian benar,
// dialog ditutup dengan Map berisi data siap kirim ke ApiService.ubahDraft;
// Batal = null.
class DialogEditDraft extends StatefulWidget {
  final ListingModel listing;

  const DialogEditDraft({super.key, required this.listing});

  @override
  State<DialogEditDraft> createState() => _DialogEditDraftState();
}

class _DialogEditDraftState extends State<DialogEditDraft> {
  late final TextEditingController namaController = TextEditingController(text: widget.listing.namaProduk);
  late final TextEditingController stokController = TextEditingController(text: '${widget.listing.stok}');
  late final TextEditingController hargaNormalController =
      TextEditingController(text: widget.listing.hargaNormal.round().toString());
  late final TextEditingController hargaMinimumController =
      TextEditingController(text: widget.listing.hargaMinimum.round().toString());
  late final TextEditingController batchController = TextEditingController(text: widget.listing.nomorBatch ?? '');
  String? _pesanGalat;

  @override
  void dispose() {
    namaController.dispose();
    stokController.dispose();
    hargaNormalController.dispose();
    hargaMinimumController.dispose();
    batchController.dispose();
    super.dispose();
  }

  void _simpan() {
    final String nama = namaController.text.trim();
    final int? stok = int.tryParse(stokController.text);
    final double? hargaNormal = double.tryParse(hargaNormalController.text);
    final double? hargaMinimum = double.tryParse(hargaMinimumController.text);
    if (nama.isEmpty || stok == null || stok <= 0 || hargaNormal == null || hargaNormal <= 0 || hargaMinimum == null || hargaMinimum <= 0) {
      setState(() => _pesanGalat = 'Harap lengkapi semua kolom dengan benar');
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      'name': nama,
      'qty': stok,
      'normal_price': hargaNormal,
      'min_price': hargaMinimum,
      'batch_number': batchController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Isi Draf'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama Produk')),
            const SizedBox(height: AppTheme.jarakKecil),
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Stok (${widget.listing.satuan})'),
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            TextField(
              controller: hargaNormalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Normal (Rp)'),
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            TextField(
              controller: hargaMinimumController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Minimum (Rp)'),
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Nomor Batch / Lot')),
            if (_pesanGalat != null) ...[
              const SizedBox(height: AppTheme.jarakKecil),
              Text(_pesanGalat!, style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaGalatTeks)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: _simpan, child: const Text('Simpan Perubahan')),
      ],
    );
  }
}
