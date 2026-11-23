import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/price_advice_model.dart';
import '../theme/app_theme.dart';
import 'kartu_rekomendasi_harga.dart';
import 'kartu_review_upload.dart';

// Isi langkah 3 upload: ringkasan draft + kartu rekomendasi harga AI.
// Tombol "Atur manual" dan "Terbitkan" ada di bar bawah layar.
class IsiTahapTerbit extends StatelessWidget {
  final ListingModel draftServer;
  final PriceAdviceModel saranHarga;
  final Uint8List? fotoLokal;
  final VoidCallback onUbahHargaAwal;

  const IsiTahapTerbit({
    super.key,
    required this.draftServer,
    required this.saranHarga,
    this.fotoLokal,
    required this.onUbahHargaAwal,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.jarakTepi),
      children: [
        KartuReviewUpload(
          draft: draftServer,
          fotoLokal: fotoLokal,
          onUbahHargaAwal: onUbahHargaAwal,
        ),
        KartuRekomendasiHarga(saran: saranHarga, draft: draftServer),
        const SizedBox(height: AppTheme.jarakKecil),
        const Text(
          'Belum ingin terbit? Draft ini tetap tersimpan di server dan bisa diedit kembali dari halaman Stok.',
          style: AppTheme.gayaTeksRedup,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
