import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'price_countdown.dart';
import 'status_badge.dart';

// Isi layar Detail Produk penjual (seller_product_detail_screen Recovera lama):
// pratinjau foto, kartu info utama, kartu Struktur Harga, hitung mundur (lelang
// aktif), dan kotak "Alur Saat Ini". Hanya tampilan; data dari layar induk.
class IsiDetailStok extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const IsiDetailStok({super.key, required this.listing, required this.onHargaTurun});

  String get _alurSaatIni {
    if (listing.masihDraft) return 'Draf: cek rekomendasi harga lalu terbitkan';
    switch (listing.status) {
      case 'active':
        return 'Lelang aktif di katalog pembeli';
      case 'sold':
        return 'Stok habis terjual';
      case 'expired':
        return 'Lelang sudah berakhir';
      default:
        return listing.labelStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? sisa = listing.sisaHari;
    final String teksSisa = sisa == null ? '' : (sisa <= 0 ? ' (sudah lewat)' : ' (sisa $sisa hari)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PratinjauFoto(urlGambar: listing.urlGambar),
        const SizedBox(height: AppTheme.jarakTepi),
        _KartuPutih(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.namaProduk,
                        style: const TextStyle(fontSize: AppTheme.fontJudulTransaksi, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
                      ),
                      if (listing.merek != null && listing.merek!.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.jarakMini),
                        Text(
                          listing.merek!,
                          style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w600, color: AppTheme.warnaJarak),
                        ),
                      ],
                    ],
                  ),
                ),
                StatusBadge(status: listing.status, label: listing.labelStatus),
              ],
            ),
            const SizedBox(height: AppTheme.jarakTepi),
            const Divider(height: 1, color: AppTheme.warnaLatarNetral),
            const SizedBox(height: AppTheme.jarakTepi),
            _BarisSpek(label: 'Kategori', nilai: listing.kategori),
            _BarisSpek(label: 'Jumlah Stok', nilai: '${listing.stok} ${listing.satuan}'),
            _BarisSpek(label: 'Nomor Batch', nilai: listing.nomorBatch ?? '-'),
            _BarisSpek(label: 'Penyimpanan', nilai: listing.jenisPenyimpanan ?? 'Suhu Ruang'),
            _BarisSpek(
              label: 'Kedaluwarsa',
              nilai: '${ListingModel.formatTanggal(listing.tanggalKedaluwarsa)}$teksSisa',
              disorot: sisa != null && sisa < 30,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.jarakTepi),
        _KartuPutih(
          children: [
            const Text(
              'Struktur Harga',
              style: TextStyle(fontSize: AppTheme.fontJudulBagian, fontWeight: FontWeight.w700, color: AppTheme.warnaNavy),
            ),
            const SizedBox(height: AppTheme.jarakInput),
            _BarisHarga(label: 'Harga Normal', nilai: listing.hargaNormal),
            _BarisHarga(label: 'Harga Lelang (Mulai)', nilai: listing.hargaMulai ?? listing.hargaSekarang, utama: true),
            if (listing.status == 'active') _BarisHarga(label: 'Harga Saat Ini', nilai: listing.hargaSekarang),
            _BarisHarga(label: 'Batas Harga Minimum', nilai: listing.hargaMinimum),
          ],
        ),
        if (listing.status == 'active' && listing.waktuTurunBerikutnya != null) ...[
          const SizedBox(height: AppTheme.jarakTepi),
          PriceCountdown(waktuTurun: listing.waktuTurunBerikutnya!, onHargaTurun: onHargaTurun),
        ],
        const SizedBox(height: AppTheme.jarakTepi),
        // Kotak info alur (bukan tombol).
        Container(
          padding: const EdgeInsets.all(AppTheme.jarakTepi),
          decoration: BoxDecoration(
            color: AppTheme.warnaIkonBiruMuda,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.warnaGarisInfo),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.jarakKecil),
                decoration: const BoxDecoration(color: AppTheme.warnaJarak, shape: BoxShape.circle),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.warnaPermukaan, size: AppTheme.ikonMata),
              ),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alur Saat Ini',
                      style: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600, color: AppTheme.warnaJarak),
                    ),
                    Text(
                      _alurSaatIni,
                      style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700, color: AppTheme.warnaNavy),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KartuPutih extends StatelessWidget {
  final List<Widget> children;

  const _KartuPutih({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakBesar),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
        border: Border.all(color: AppTheme.warnaGaris),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _PratinjauFoto extends StatelessWidget {
  final String? urlGambar;

  const _PratinjauFoto({required this.urlGambar});

  @override
  Widget build(BuildContext context) {
    const Widget cadangan = ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: AppTheme.ikonPin, color: AppTheme.warnaTeksRedup),
          SizedBox(height: AppTheme.jarakKecil),
          Text('Foto Tidak Tersedia', style: TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w600, color: AppTheme.warnaTeksRedup)),
        ],
      ),
    );
    return Container(
      height: AppTheme.tinggiPratinjauStok,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
        border: Border.all(color: AppTheme.warnaGarisInfo),
      ),
      child: (urlGambar == null || urlGambar!.isEmpty)
          ? cadangan
          : Image.network(urlGambar!, fit: BoxFit.contain, errorBuilder: (c, e, s) => cadangan),
    );
  }
}

// Baris spesifikasi: label lebar tetap di kiri, nilai di kanan (merah bila disorot).
class _BarisSpek extends StatelessWidget {
  final String label;
  final String nilai;
  final bool disorot;

  const _BarisSpek({required this.label, required this.nilai, this.disorot = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.radiusSedang),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppTheme.lebarLabelSpek,
            child: Text(label, style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w500, color: AppTheme.warnaTeksRedup)),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: Text(
              nilai,
              style: TextStyle(
                fontSize: AppTheme.fontNormal,
                fontWeight: FontWeight.w600,
                color: disorot ? AppTheme.warnaGalatTeks : AppTheme.warnaJudulKartu,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Baris harga: label kiri, nominal kanan; baris utama (harga mulai) lebih tebal & biru.
class _BarisHarga extends StatelessWidget {
  final String label;
  final double nilai;
  final bool utama;

  const _BarisHarga({required this.label, required this.nilai, this.utama = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fontNormal,
                fontWeight: utama ? FontWeight.w700 : FontWeight.w500,
                color: utama ? AppTheme.warnaNavy : AppTheme.warnaTeksRedup,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Text(
            ListingModel.formatRupiah(nilai),
            style: TextStyle(
              fontSize: utama ? AppTheme.fontSubjudul : AppTheme.fontSedang,
              fontWeight: utama ? FontWeight.w800 : FontWeight.w600,
              color: utama ? AppTheme.warnaJarak : AppTheme.warnaJudulKartu,
            ),
          ),
        ],
      ),
    );
  }
}
