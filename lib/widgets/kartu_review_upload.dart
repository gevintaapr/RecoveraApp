import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'baris_info.dart';

// Kartu Review Data Produk sebelum Terbit (T7).
// Menampilkan ringkasan data produk, batch, harga normal, harga minimum,
// dan tombol untuk mengubah harga awal lelang secara manual.
class KartuReviewUpload extends StatelessWidget {
  final ListingModel draft;
  final Uint8List? fotoLokal;
  final VoidCallback onUbahHargaAwal;

  const KartuReviewUpload({
    super.key,
    required this.draft,
    this.fotoLokal,
    required this.onUbahHargaAwal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppTheme.warnaGaris),
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppTheme.jarakKecil,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.rate_review_outlined,
                      color: AppTheme.warnaUtama,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.jarakKecil),
                    Text('Review Data Listing', style: AppTheme.gayaSubjudul),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                  label: const Text('Ubah Harga Awal'),
                  onPressed: onUbahHargaAwal,
                ),
              ],
            ),
            const Divider(height: AppTheme.jarakSedang),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radius / 2),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: _buildGambar(),
                  ),
                ),
                const SizedBox(width: AppTheme.jarakSedang),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.namaProduk,
                        style: const TextStyle(
                          fontSize: AppTheme.fontNormal,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warnaTeks,
                        ),
                      ),
                      if (draft.merek != null && draft.merek!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Merek: ${draft.merek}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontKecil,
                            color: AppTheme.warnaTeksRedup,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${draft.stok} ${draft.satuan} · Lot: ${draft.nomorBatch ?? '-'}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontKecil,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warnaUtama,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            BarisInfo(
              label: 'Harga normal',
              nilai: ListingModel.formatRupiah(draft.hargaNormal),
            ),
            BarisInfo(
              label: 'Batas minimum',
              nilai: ListingModel.formatRupiah(draft.hargaMinimum),
            ),
            BarisInfo(
              label: 'Kedaluwarsa',
              nilai: ListingModel.formatTanggal(draft.tanggalKedaluwarsa),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGambar() {
    if (fotoLokal != null) {
      return Image.memory(fotoLokal!, fit: BoxFit.cover);
    }
    if (draft.urlGambar != null && draft.urlGambar!.isNotEmpty) {
      return Image.network(
        draft.urlGambar!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _gambarCadangan(),
      );
    }
    return _gambarCadangan();
  }

  Widget _gambarCadangan() {
    return Container(
      color: AppTheme.warnaGaris,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.warnaTeksRedup,
      ),
    );
  }
}

