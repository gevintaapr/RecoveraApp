import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/price_advice_model.dart';
import '../theme/app_theme.dart';
import 'kartu_rekomendasi_harga.dart';
import 'primary_button.dart';

// Tombol aksi di bawah Detail Produk penjual, sesuai status listing:
// - draft : Lihat Rekomendasi Harga -> (kartu saran + Terbitkan), Edit Draf, Hapus Draf
// - aktif : Ubah Stok / Harga Minimum
// - lain  : teks keterangan
// Hanya tampilan; aksinya dikirim lewat callback dari layar induk.
class AksiDetailStok extends StatelessWidget {
  final ListingModel listing;
  final PriceAdviceModel? saranHarga;
  final bool sedangMemuatSaran;
  final VoidCallback onLihatRekomendasi;
  final VoidCallback onTerbitkan;
  final VoidCallback onEditDraft;
  final VoidCallback onHapusDraft;
  final VoidCallback onUbahStok;

  const AksiDetailStok({
    super.key,
    required this.listing,
    required this.saranHarga,
    required this.sedangMemuatSaran,
    required this.onLihatRekomendasi,
    required this.onTerbitkan,
    required this.onEditDraft,
    required this.onHapusDraft,
    required this.onUbahStok,
  });

  @override
  Widget build(BuildContext context) {
    if (listing.masihDraft) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saranHarga == null)
            PrimaryButton(
              teks: 'Lihat Rekomendasi Harga',
              ikon: Icons.auto_graph_rounded,
              sedangMemuat: sedangMemuatSaran,
              onPressed: onLihatRekomendasi,
            )
          else ...[
            KartuRekomendasiHarga(saran: saranHarga!, draft: listing),
            const SizedBox(height: AppTheme.jarakSedang),
            PrimaryButton(teks: 'Terbitkan', ikon: Icons.rocket_launch_outlined, onPressed: onTerbitkan),
          ],
          const SizedBox(height: AppTheme.jarakSedang),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppTheme.tinggiTombol)),
            onPressed: onEditDraft,
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Lanjutkan Upload & Edit Draf'),
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.warnaGalatTeks,
              minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
            ),
            onPressed: onHapusDraft,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus Draf Produk'),
          ),
        ],
      );
    }

    if (listing.status == 'active') {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppTheme.tinggiTombol)),
        onPressed: onUbahStok,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Ubah Stok / Harga Minimum'),
      );
    }

    return Text(
      listing.status == 'sold' ? 'Stok sudah habis terjual.' : 'Lelang sudah berakhir.',
      textAlign: TextAlign.center,
      style: AppTheme.gayaTeksRedup,
    );
  }
}
