import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'baris_info.dart';
import 'chip_lembut.dart';
import 'foto_hero_listing.dart';
import 'kartu_bagian.dart';
import 'price_countdown.dart';
import 'tombol_ingatkan.dart';

// Isi halaman detail listing pembeli (dipisah dari layar agar layar < 250 baris):
// foto hero -> kartu harga -> kartu Lelang Belanda (hitung mundur + pengingat)
// -> kartu Spesifikasi. Semua harga dari server; tidak ada hitung ulang di HP.
class IsiDetailListing extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const IsiDetailListing({super.key, required this.listing, required this.onHargaTurun});

  // Jarak dari server bila ada; kalau tidak, dihitung dari lokasi HP terakhir.
  double? get _jarakKeGudang {
    if (listing.jarakKm != null) return listing.jarakKm;
    final Position? lokasi = LocationService.lokasiTerakhir;
    if (lokasi == null || listing.latGudang == null || listing.lngGudang == null) return null;
    return LocationService.hitungJarakKm(
      lokasi.latitude,
      lokasi.longitude,
      listing.latGudang!,
      listing.lngGudang!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double? jarak = _jarakKeGudang;
    final String? teksJarak = jarak == null ? null : ListingModel.formatJarak(jarak);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTheme.jarakSedang, AppTheme.jarakKecil, AppTheme.jarakSedang, AppTheme.jarakBesar),
      children: [
        FotoHeroListing(listing: listing, teksJarak: teksJarak),
        const SizedBox(height: AppTheme.jarakKecil),
        _KartuHarga(listing: listing),
        const SizedBox(height: AppTheme.jarakKecil),
        _KartuLelang(listing: listing, onHargaTurun: onHargaTurun),
        const SizedBox(height: AppTheme.jarakKecil),
        _KartuSpesifikasi(listing: listing, teksJarak: teksJarak),
      ],
    );
  }
}

class _KartuHarga extends StatelessWidget {
  final ListingModel listing;

  const _KartuHarga({required this.listing});

  @override
  Widget build(BuildContext context) {
    return KartuBagian(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga sekarang', style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup)),
                  Wrap(
                    spacing: AppTheme.jarakMini,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        ListingModel.formatRupiah(listing.hargaSekarang),
                        style: AppTheme.gayaHarga.copyWith(fontSize: AppTheme.fontBesar),
                      ),
                      Text('/${listing.satuan}', style: AppTheme.gayaTeksRedup.copyWith(fontSize: AppTheme.fontKecil)),
                      Text(ListingModel.formatRupiah(listing.hargaNormal), style: AppTheme.gayaHargaCoret),
                    ],
                  ),
                ],
              ),
            ),
            if (listing.diskonPersen > 0)
              ChipLembut(
                teks: '-${listing.diskonPersen}%',
                warnaLatar: AppTheme.warnaLatarSukses,
                warnaTeks: AppTheme.warnaSukses,
              ),
          ],
        ),
      ],
    );
  }
}

class _KartuLelang extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const _KartuLelang({required this.listing, required this.onHargaTurun});

  @override
  Widget build(BuildContext context) {
    final DateTime? turunBerikutnya = listing.waktuTurunBerikutnya;
    final String teksMinimum = ListingModel.formatRupiah(listing.hargaMinimum);

    return KartuBagian(
      judul: 'Lelang Belanda',
      children: [
        if (turunBerikutnya == null)
          ChipLembut(teks: 'Harga sudah di batas terendah ($teksMinimum)')
        else
          PriceCountdown(
            waktuTurun: turunBerikutnya,
            onHargaTurun: onHargaTurun,
            teksHargaMinimum: teksMinimum,
          ),
        const SizedBox(height: AppTheme.jarakKecil),
        Row(
          children: [
            Expanded(
              child: _KotakNilai(
                label: 'Lelang berakhir',
                nilai: '${ListingModel.formatTanggal(listing.lelangBerakhir)}, '
                    '${ListingModel.formatJam(listing.lelangBerakhir)}',
              ),
            ),
            if (listing.hargaMulai != null) ...[
              const SizedBox(width: AppTheme.jarakKecil),
              Expanded(
                child: _KotakNilai(label: 'Harga mulai', nilai: ListingModel.formatRupiah(listing.hargaMulai!)),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        TombolIngatkan(favorit: FavoritModel.dariListing(listing)),
      ],
    );
  }
}

class _KotakNilai extends StatelessWidget {
  final String label;
  final String nilai;

  const _KotakNilai({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakKecil),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.warnaGaris),
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup)),
          Text(nilai, style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _KartuSpesifikasi extends StatelessWidget {
  final ListingModel listing;
  final String? teksJarak;

  const _KartuSpesifikasi({required this.listing, required this.teksJarak});

  @override
  Widget build(BuildContext context) {
    final int? sisaHari = listing.sisaHari;
    final String gudang = [listing.kotaGudang ?? '-', ?teksJarak].join(' · ');

    return KartuBagian(
      judul: 'Spesifikasi',
      kanan: ChipLembut(
        teks: 'Stok ${listing.stok} ${listing.satuan}',
        warnaLatar: AppTheme.warnaLatarSukses,
        warnaTeks: AppTheme.warnaSukses,
      ),
      children: [
        BarisInfo(label: 'Kategori', nilai: listing.kategori),
        BarisInfo(label: 'Nomor batch', nilai: listing.nomorBatch ?? '-'),
        BarisInfo(label: 'Penyimpanan', nilai: listing.jenisPenyimpanan ?? '-'),
        BarisInfo(
          label: 'Kedaluwarsa',
          nilai: sisaHari == null
              ? ListingModel.formatTanggal(listing.tanggalKedaluwarsa)
              : '${ListingModel.formatTanggal(listing.tanggalKedaluwarsa)} · sisa $sisaHari hari',
          warnaNilai: (sisaHari ?? 999) <= 14 ? AppTheme.warnaSisaHari : null,
        ),
        BarisInfo(label: 'Penjual', nilai: listing.namaPenjual ?? '-'),
        BarisInfo(label: 'Gudang', nilai: gudang),
        const BarisInfo(label: 'Metode', nilai: 'Ambil di gudang'),
      ],
    );
  }
}
