import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'empty_state.dart';
import 'judul_bagian.dart';
import 'label_data_offline.dart';
import 'listing_card.dart';

// Isi katalog setelah data berhasil dimuat: label "Data offline" (bila dari
// cache Hive), judul bagian, lalu kartu listing. Tarik ke bawah = muat ulang.
class DaftarKatalog extends StatelessWidget {
  final List<ListingModel> daftarListing;
  final bool dataOffline;
  final bool urutTerdekat;
  final Future<void> Function() onMuatUlang;
  final ValueChanged<ListingModel> onBukaDetail;
  final VoidCallback onHargaTurun;

  const DaftarKatalog({
    super.key,
    required this.daftarListing,
    required this.dataOffline,
    required this.urutTerdekat,
    required this.onMuatUlang,
    required this.onBukaDetail,
    required this.onHargaTurun,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (dataOffline) const LabelDataOffline(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onMuatUlang,
            child: ListView(
              // Jarak bawah = tinggi bar navigasi (extendBody) + jarak biasa.
              padding: EdgeInsets.fromLTRB(
                AppTheme.jarakTepi,
                AppTheme.jarakMini,
                AppTheme.jarakTepi,
                MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang,
              ),
              children: [
                JudulBagian(
                  ikon: Icons.radar_rounded,
                  judul: urutTerdekat ? 'Rekomendasi Terdekat' : 'Daftar Produk',
                  teksKanan: '${daftarListing.length} Produk',
                ),
                if (daftarListing.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: AppTheme.jarakBesar),
                    child: EmptyState(
                      ikon: Icons.search_off,
                      pesan:
                          'Tidak ada lelang yang cocok.\nUbah kata kunci atau hapus filter di atas.',
                    ),
                  )
                else
                  ...daftarListing.map((listing) => ListingCard(
                        listing: listing,
                        onTap: () => onBukaDetail(listing),
                        onHargaTurun: onHargaTurun,
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
