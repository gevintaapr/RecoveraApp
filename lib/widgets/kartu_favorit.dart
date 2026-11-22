import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../screens/buyer/listing_detail_screen.dart';
import '../theme/app_theme.dart';
import 'chip_lembut.dart';
import 'tombol_favorit.dart';
import 'tombol_ingatkan.dart';

// Kartu satu produk di halaman Favorit: foto, penjual, nama, harga saat disimpan,
// status lelang, lalu tombol lonceng (pengingat) dan hati (hapus favorit).
// Ketuk kartu -> detail, yang memuat harga terbaru dari server.
class KartuFavorit extends StatelessWidget {
  final FavoritModel favorit;

  const KartuFavorit({super.key, required this.favorit});

  @override
  Widget build(BuildContext context) {
    final bool berakhir = favorit.lelangSudahBerakhir;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
          side: const BorderSide(color: AppTheme.warnaGaris),
        ),
        child: InkWell(
          // Detail memuat harga terbaru dari server (Navigator.push + idListing, Modul IV).
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListingDetailScreen(idListing: favorit.idListing)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(AppTheme.radiusTombol), child: _gambar()),
                const SizedBox(width: AppTheme.jarakSedang),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (favorit.namaPenjual != null)
                        Text(
                          favorit.namaPenjual!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.gayaLabelKapital,
                        ),
                      Text(
                        favorit.namaProduk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTheme.fontSedang,
                          fontWeight: FontWeight.w700,
                          color: berakhir ? AppTheme.warnaTeksSedang : AppTheme.warnaTeks,
                        ),
                      ),
                      Wrap(
                        spacing: AppTheme.jarakMini,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            ListingModel.formatRupiah(favorit.hargaSaatDisimpan),
                            style: AppTheme.gayaHarga.copyWith(
                              color: berakhir ? AppTheme.warnaTeksRedup : AppTheme.warnaUtama,
                            ),
                          ),
                          Text(
                            'saat disimpan · ${ListingModel.formatTanggal(favorit.waktuDisimpan)}',
                            style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.jarakMini / 2),
                      berakhir
                          ? const ChipLembut(
                              teks: 'Lelang berakhir',
                              warnaLatar: AppTheme.warnaLatarBahaya,
                              warnaTeks: AppTheme.warnaTeksPeringatan,
                            )
                          : const ChipLembut(
                              teks: 'Lelang berlangsung',
                              warnaLatar: AppTheme.warnaLatarSukses,
                              warnaTeks: AppTheme.warnaSukses,
                            ),
                    ],
                  ),
                ),
                // Lonceng: pasang/batalkan pengingat 30 menit sebelum lelang berakhir (Modul VII).
                if (!berakhir) TombolIngatkan(favorit: favorit, bentukIkon: true),
                TombolFavorit(favorit: favorit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gambar() {
    const Widget gambarCadangan = SizedBox(
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      child: ColoredBox(
        color: AppTheme.warnaLatarNetral,
        child: Icon(Icons.inventory_2_outlined, color: AppTheme.warnaTeksRedup),
      ),
    );
    if (favorit.urlGambar == null || favorit.urlGambar!.isEmpty) return gambarCadangan;
    return Image.network(
      favorit.urlGambar!,
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => gambarCadangan,
    );
  }
}
