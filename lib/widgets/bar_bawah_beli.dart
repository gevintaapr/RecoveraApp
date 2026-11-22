import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Bar bawah Detail produk (_buildStickyBottomBar Recovera lama):
// baris 1 = "Jumlah Pembelian" + pengatur jumlah (1..stok),
// baris 2 = Total Pembayaran (perkiraan) + tombol "Beli Sekarang".
// Harga final tetap dikunci server saat dibeli.
class BarBawahBeli extends StatelessWidget {
  final ListingModel listing;
  final int jumlah;
  final ValueChanged<int> onJumlahDiubah;
  final VoidCallback onBeliDitekan;

  const BarBawahBeli({
    super.key,
    required this.listing,
    required this.jumlah,
    required this.onJumlahDiubah,
    required this.onBeliDitekan,
  });

  bool get _stokTersedia => listing.stok > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppTheme.jarakTepi, AppTheme.jarakKecil, AppTheme.jarakTepi, AppTheme.radiusSedang),
      decoration: const BoxDecoration(
        color: AppTheme.warnaPermukaan,
        boxShadow: [BoxShadow(color: AppTheme.warnaBayanganBar, blurRadius: 12, offset: Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jumlah Pembelian',
                        style: TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu),
                      ),
                      Text(
                        _stokTersedia ? '(Min: 1 ${listing.satuan} | Stok: ${listing.stok})' : 'Stok habis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                      ),
                    ],
                  ),
                ),
                if (_stokTersedia)
                  _PengaturJumlah(
                    jumlah: jumlah,
                    bisaKurang: jumlah > 1,
                    bisaTambah: jumlah < listing.stok,
                    onUbah: onJumlahDiubah,
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            const Divider(color: AppTheme.warnaLatarNetral),
            const SizedBox(height: AppTheme.jarakKecil),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran ($jumlah ${listing.satuan}):',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ListingModel.formatRupiah(listing.hargaSekarang * jumlah),
                          style: const TextStyle(
                            fontSize: AppTheme.fontJudulTransaksi,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warnaUtama,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.jarakSedang),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, AppTheme.ukuranTombolIkon),
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar, vertical: AppTheme.radiusSedang),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
                    elevation: 1,
                    textStyle: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: AppTheme.ikonKecil),
                  label: Text(_stokTersedia ? 'Beli Sekarang' : 'Stok Habis'),
                  onPressed: _stokTersedia ? onBeliDitekan : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pengatur jumlah abu-abu [-] angka [+] (stepper lama). Area ketuk tiap tombol 44.
class _PengaturJumlah extends StatelessWidget {
  final int jumlah;
  final bool bisaKurang;
  final bool bisaTambah;
  final ValueChanged<int> onUbah;

  const _PengaturJumlah({required this.jumlah, required this.bisaKurang, required this.bisaTambah, required this.onUbah});

  Widget _tombol({required IconData ikon, required String keterangan, required bool aktif, required Color warnaAktif, required VoidCallback onTap}) {
    return IconButton(
      tooltip: keterangan,
      onPressed: aktif ? onTap : null,
      constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon, minHeight: AppTheme.ukuranTombolIkon),
      icon: Icon(ikon, size: AppTheme.ikonKecil, color: aktif ? warnaAktif : AppTheme.warnaTeksRedup),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarNetral,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tombol(ikon: Icons.remove_rounded, keterangan: 'Kurangi', aktif: bisaKurang, warnaAktif: AppTheme.warnaJudulKartu, onTap: () => onUbah(jumlah - 1)),
          Container(
            constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon),
            height: AppTheme.tombolPanah,
            alignment: Alignment.center,
            color: AppTheme.warnaPermukaan,
            child: Text('$jumlah', style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu)),
          ),
          _tombol(ikon: Icons.add_rounded, keterangan: 'Tambah', aktif: bisaTambah, warnaAktif: AppTheme.warnaUtama, onTap: () => onUbah(jumlah + 1)),
        ],
      ),
    );
  }
}
