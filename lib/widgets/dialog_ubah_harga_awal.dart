import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Dialog "Ubah Harga Awal Manual" di langkah 3 upload (T7).
// Mengembalikan teks harga yang diketik bila penjual menekan Simpan,
// atau null bila Batal. Validasi angka tetap dilakukan layar pemanggil.
Future<String?> tampilkanDialogUbahHargaAwal(
  BuildContext context, {
  required double hargaAwal,
  required double batasBawah,
  required double batasAtas,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DialogUbahHargaAwal(
      hargaAwal: hargaAwal,
      batasBawah: batasBawah,
      batasAtas: batasAtas,
    ),
  );
}

class _DialogUbahHargaAwal extends StatefulWidget {
  final double hargaAwal;
  final double batasBawah;
  final double batasAtas;

  const _DialogUbahHargaAwal({
    required this.hargaAwal,
    required this.batasBawah,
    required this.batasAtas,
  });

  @override
  State<_DialogUbahHargaAwal> createState() => _DialogUbahHargaAwalState();
}

class _DialogUbahHargaAwalState extends State<_DialogUbahHargaAwal> {
  late final TextEditingController hargaAwalController =
      TextEditingController(text: widget.hargaAwal.round().toString());

  @override
  void dispose() {
    hargaAwalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? nilaiInput = double.tryParse(hargaAwalController.text);
    final bool diLuarRentang = nilaiInput != null &&
        (nilaiInput < widget.batasBawah || nilaiInput > widget.batasAtas);

    return AlertDialog(
      title: const Text('Ubah Harga Awal Manual'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentukan harga mulai lelang sebelum diterbitkan.',
              style: TextStyle(
                fontSize: AppTheme.fontKecil,
                color: AppTheme.warnaTeksRedup,
              ),
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            Text(
              'Rentang wajar AI: ${ListingModel.formatRupiah(widget.batasBawah)} – ${ListingModel.formatRupiah(widget.batasAtas)}',
              style: const TextStyle(
                fontSize: AppTheme.fontKecil,
                fontWeight: FontWeight.w600,
                color: AppTheme.warnaUtama,
              ),
            ),
            const SizedBox(height: AppTheme.jarakSedang),
            TextField(
              controller: hargaAwalController,
              keyboardType: TextInputType.number,
              // setState di sini supaya peringatan rentang ikut berubah saat mengetik.
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Harga Mulai Lelang (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            if (diLuarRentang) ...[
              const SizedBox(height: AppTheme.jarakKecil),
              const _PeringatanLuarRentang(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, hargaAwalController.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _PeringatanLuarRentang extends StatelessWidget {
  const _PeringatanLuarRentang();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakKecil),
      decoration: BoxDecoration(
        color: AppTheme.warnaAksen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaAksen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.warnaAksen),
          SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: Text(
              'Peringatan: Harga berada di luar rentang saran AI. Anda akan diminta menyetujui konfirmasi saat menerbitkan.',
              style: TextStyle(
                fontSize: AppTheme.fontKecil,
                color: AppTheme.warnaAksen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
