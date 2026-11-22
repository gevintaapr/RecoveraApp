import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'foto_hero_listing.dart';
import 'kartu_lelang_detail.dart';
import 'tombol_ingatkan.dart';

// Isi Detail produk (susunan product_detail_screen Recovera lama):
// kartu hero -> kartu harga -> Mekanisme Dutch Auction -> Spesifikasi Batch & Logistik.
// Semua angka dari server; tidak ada hitung ulang harga di HP.
class IsiDetailListing extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const IsiDetailListing({super.key, required this.listing, required this.onHargaTurun});

  // Jarak dari server bila ada; kalau tidak, dihitung dari lokasi HP terakhir.
  double? get _jarakKeGudang {
    if (listing.jarakKm != null) return listing.jarakKm;
    final Position? lokasi = LocationService.lokasiTerakhir;
    if (lokasi == null || listing.latGudang == null || listing.lngGudang == null) return null;
    return LocationService.hitungJarakKm(lokasi.latitude, lokasi.longitude, listing.latGudang!, listing.lngGudang!);
  }

  @override
  Widget build(BuildContext context) {
    final double? jarak = _jarakKeGudang;
    final String? teksJarak = jarak == null ? null : ListingModel.formatJarak(jarak);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTheme.jarakInput, AppTheme.jarakLabel, AppTheme.jarakInput, AppTheme.jarakBesar),
      children: [
        FotoHeroListing(listing: listing, teksJarak: teksJarak),
        const SizedBox(height: AppTheme.jarakKecil),
        _KartuHarga(listing: listing),
        const SizedBox(height: AppTheme.jarakKecil),
        KartuSeksiDetail(
          judul: 'Mekanisme Dutch Auction',
          children: [
            KartuLelangDetail(listing: listing, onHargaTurun: onHargaTurun),
            const SizedBox(height: AppTheme.radiusSedang),
            TombolIngatkan(favorit: FavoritModel.dariListing(listing)),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        _KartuSpesifikasi(listing: listing, teksJarak: teksJarak),
      ],
    );
  }
}

// Kartu putih satu seksi di Detail produk (radius 12, bayangan tipis seperti versi lama).
class KartuSeksiDetail extends StatelessWidget {
  final String judul;
  final Widget? lencana;
  final List<Widget> children;

  const KartuSeksiDetail({super.key, required this.judul, this.lencana, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 6, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(judul, style: const TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu)),
              ),
              ?lencana,
            ],
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          ...children,
        ],
      ),
    );
  }
}

class _KartuHarga extends StatelessWidget {
  final ListingModel listing;

  const _KartuHarga({required this.listing});

  @override
  Widget build(BuildContext context) {
    return KartuSeksiDetail(
      judul: 'Harga Lelang Saat Ini',
      lencana: listing.diskonPersen > 0
          ? _Lencana(teks: 'Diskon ${listing.diskonPersen}%', latar: AppTheme.warnaLatarStok, warnaTeks: AppTheme.warnaSisaAman)
          : null,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppTheme.jarakLabel,
          children: [
            Text(
              ListingModel.formatRupiah(listing.hargaSekarang),
              style: const TextStyle(fontSize: AppTheme.fontBesar, fontWeight: FontWeight.w800, color: AppTheme.warnaUtama, letterSpacing: -0.3),
            ),
            Text('/ ${listing.satuan}', style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup)),
            Text(
              ListingModel.formatRupiah(listing.hargaNormal),
              style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup, decoration: TextDecoration.lineThrough),
            ),
          ],
        ),
      ],
    );
  }
}

class _KartuSpesifikasi extends StatelessWidget {
  final ListingModel listing;
  final String? teksJarak;

  const _KartuSpesifikasi({required this.listing, required this.teksJarak});

  @override
  Widget build(BuildContext context) {
    final int? sisa = listing.sisaHari;
    return KartuSeksiDetail(
      judul: 'Spesifikasi Batch & Logistik',
      lencana: _Lencana(teks: 'Stok: ${listing.stok} ${listing.satuan}', latar: AppTheme.warnaLatarStok, warnaTeks: AppTheme.warnaSisaAman),
      children: [
        _BarisSpek(label: 'Kategori', nilai: listing.kategori),
        _BarisSpek(label: 'Merek', nilai: listing.merek ?? '-'),
        _BarisSpek(
          label: 'Kedaluwarsa',
          nilai: ListingModel.formatTanggal(listing.tanggalKedaluwarsa),
          lencana: sisa == null
              ? null
              : _Lencana(
                  teks: sisa > 0 ? 'Sisa $sisa Hari' : 'Sudah Kedaluwarsa',
                  latar: sisa <= 3 ? AppTheme.warnaLatarMendesak : AppTheme.warnaLatarKedaluwarsa,
                  warnaTeks: sisa <= 3 ? AppTheme.warnaTeksMendesak : AppTheme.warnaSisaSedang,
                ),
        ),
        _BarisSpek(
          label: 'Metode Pengambilan',
          nilai: 'Ambil di gudang (${listing.kotaGudang ?? '-'})',
          lencana: teksJarak == null ? null : _Lencana(teks: teksJarak!, latar: AppTheme.warnaLatarNetral, warnaTeks: AppTheme.warnaTeksSedang),
        ),
        _BarisSpek(label: 'Penjual', nilai: listing.namaPenjual ?? '-', tanpaGaris: true),
      ],
    );
  }
}

// Baris "label | nilai | lencana" (_buildSimpleSpecRow lama), dipisah garis tipis.
class _BarisSpek extends StatelessWidget {
  final String label;
  final String nilai;
  final Widget? lencana;
  final bool tanpaGaris;

  const _BarisSpek({required this.label, required this.nilai, this.lencana, this.tanpaGaris = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakLabel),
      decoration: BoxDecoration(
        border: tanpaGaris ? null : const Border(bottom: BorderSide(color: AppTheme.warnaLatarNetral)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppTheme.lebarLabelSpek,
            child: Text(label, style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup)),
          ),
          Expanded(
            child: Text(nilai, style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600, color: AppTheme.warnaJudulKartu)),
          ),
          if (lencana != null) ...[const SizedBox(width: AppTheme.jarakLabel), lencana!],
        ],
      ),
    );
  }
}

class _Lencana extends StatelessWidget {
  final String teks;
  final Color latar;
  final Color warnaTeks;

  const _Lencana({required this.teks, required this.latar, required this.warnaTeks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakLabel, vertical: AppTheme.jarakTipis),
      decoration: BoxDecoration(color: latar, borderRadius: BorderRadius.circular(AppTheme.jarakMini)),
      child: Text(teks, style: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700, color: warnaTeks)),
    );
  }
}
