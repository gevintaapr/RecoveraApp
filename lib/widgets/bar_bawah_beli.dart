import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'bar_bawah_kaca.dart';
import 'primary_button.dart';

// Bar bawah kaca di halaman detail listing (T1):
// baris 1 = pengatur jumlah (1..stok), baris 2 = perkiraan total + tombol Beli.
// Total hanya perkiraan; harga final dikunci server saat dibeli.
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
  double get _totalPerkiraan => listing.hargaSekarang * jumlah;

  @override
  Widget build(BuildContext context) {
    return BarBawahKaca(
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
                      'Jumlah',
                      style: TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _stokTersedia ? 'Stok ${listing.stok} ${listing.satuan}' : 'Stok habis',
                      style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perkiraan total ($jumlah ${listing.satuan})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ListingModel.formatRupiah(_totalPerkiraan),
                        style: AppTheme.gayaHarga.copyWith(fontSize: AppTheme.fontBesar),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: PrimaryButton(
                  teks: _stokTersedia ? 'Beli sekarang' : 'Stok habis',
                  ikon: Icons.shopping_bag_outlined,
                  onPressed: _stokTersedia ? onBeliDitekan : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Kapsul [-] angka [+]. Tombol bulat terlihat 32, area ketuk 44.
class _PengaturJumlah extends StatelessWidget {
  final int jumlah;
  final bool bisaKurang;
  final bool bisaTambah;
  final ValueChanged<int> onUbah;

  const _PengaturJumlah({
    required this.jumlah,
    required this.bisaKurang,
    required this.bisaTambah,
    required this.onUbah,
  });

  Widget _tombol({required IconData ikon, required String keterangan, required VoidCallback? onTap}) {
    return IconButton(
      tooltip: keterangan,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon, minHeight: AppTheme.ukuranTombolIkon),
      icon: Container(
        width: AppTheme.ukuranTombolKecil,
        height: AppTheme.ukuranTombolKecil,
        decoration: const BoxDecoration(color: AppTheme.warnaPermukaan, shape: BoxShape.circle),
        child: Icon(ikon, size: AppTheme.ikonKecil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarNetral,
        borderRadius: BorderRadius.circular(AppTheme.radiusKapsul),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tombol(ikon: Icons.remove, keterangan: 'Kurangi', onTap: bisaKurang ? () => onUbah(jumlah - 1) : null),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolKecil),
            child: Text(
              '$jumlah',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w800),
            ),
          ),
          _tombol(ikon: Icons.add, keterangan: 'Tambah', onTap: bisaTambah ? () => onUbah(jumlah + 1) : null),
        ],
      ),
    );
  }
}
