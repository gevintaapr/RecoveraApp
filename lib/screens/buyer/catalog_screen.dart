import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/location_service.dart';
import '../../services/sensor_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/header_katalog.dart';
import '../../widgets/label_data_offline.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/pil_filter_aktif.dart';
import '../auth/login_screen.dart';
import 'listing_detail_screen.dart';

// Tab Katalog (pembeli): daftar listing lelang pangan B2B (T2).
// Data: ApiService.ambilDaftarListing() lewat FutureBuilder.
// Mendukung filter kategori, radius jarak, sisa umur kedaluwarsa,
// dan pengurutan (terdekat, termurah, segera exp, diskon tertinggi).
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _pencarianController = TextEditingController();
  late Future<List<ListingModel>> _futureListing;
  bool _dataOffline = false;
  Position? _lokasiSaya;
  String? _pesanLokasi;
  String? _namaKota;
  String _namaPengguna = '';
  FilterKatalog _filter = const FilterKatalog();
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _muatNamaPengguna();
    _futureListing = _ambilKatalog();
    _sensorService.mulaiDeteksiGoyang(_muatUlangKarenaGoyang);
  }

  Future<void> _muatNamaPengguna() async {
    final String? nama = await SessionService.ambilNamaPengguna();
    if (mounted && nama != null) setState(() => _namaPengguna = nama);
  }

  bool _sedangMemperbaruiHarga = false;

  Future<void> _perbaruiHarga() async {
    if (_sedangMemperbaruiHarga) return;
    _sedangMemperbaruiHarga = true;
    try {
      final List<ListingModel> daftarBaru = await _ambilKatalog();
      if (!mounted) return;
      setState(() {
        _futureListing = Future<List<ListingModel>>.value(daftarBaru);
      });
    } catch (_) {
      // Gagal diam-diam; data lama tetap tampil.
    } finally {
      _sedangMemperbaruiHarga = false;
    }
  }

  void _muatUlangKarenaGoyang() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('HP digoyang, memuat ulang katalog...')),
    );
    _muatUlang();
  }

  // Fetch dari server dengan filter lanjutan; fallback ke cache Hive.
  Future<List<ListingModel>> _ambilKatalog() async {
    final String kataKunci = _pencarianController.text.trim();
    if (_lokasiSaya == null) await _ambilLokasi();

    // Urutan 'discount' diurutkan di HP karena server tidak punya parameter 'discount'
    final String? urutanApi =
        _filter.urutan == 'discount' ? null : _filter.urutan;

    try {
      final List<ListingModel> daftarListing =
          await ApiService.ambilDaftarListing(
        kataKunci: kataKunci,
        kategori: _filter.kategori,
        lat: _lokasiSaya?.latitude,
        lng: _lokasiSaya?.longitude,
        radiusKm: _filter.radiusKm,
        urutan: urutanApi,
      );

      // Simpan cache bila tanpa filter apa pun
      if (kataKunci.isEmpty &&
          _filter.kategori == null &&
          _filter.radiusKm == null &&
          _filter.maksSisaHari == null) {
        await LocalDbService.simpanCacheKatalog(daftarListing);
      }
      _dataOffline = false;

      // Saring sisa hari & urutkan diskon di HP
      return _terapkanFilterLokal(daftarListing);
    } catch (e) {
      if (e.toString().contains('Sesi berakhir')) rethrow;
      final List<ListingModel> cache = LocalDbService.ambilCacheKatalog();
      if (cache.isEmpty) rethrow;
      _dataOffline = true;

      // Pencarian & penyaringan saat offline
      final String kunci = kataKunci.toLowerCase();
      List<ListingModel> hasil = cache.where((item) {
        final bool cocokTeks = kunci.isEmpty ||
            item.namaProduk.toLowerCase().contains(kunci) ||
            (item.merek ?? '').toLowerCase().contains(kunci);
        final bool cocokKategori = _filter.kategori == null ||
            item.kategori.toLowerCase() == _filter.kategori!.toLowerCase();
        final bool cocokRadius = _filter.radiusKm == null ||
            (item.jarakKm ?? 0) <= _filter.radiusKm!;
        return cocokTeks && cocokKategori && cocokRadius;
      }).toList();

      return _terapkanFilterLokal(hasil);
    }
  }

  List<ListingModel> _terapkanFilterLokal(List<ListingModel> daftar) {
    List<ListingModel> hasil = daftar;
    if (_filter.maksSisaHari != null) {
      hasil = hasil
          .where((item) =>
              item.sisaHari != null && item.sisaHari! <= _filter.maksSisaHari!)
          .toList();
    }
    if (_filter.urutan == 'discount') {
      hasil.sort((a, b) => b.diskonPersen.compareTo(a.diskonPersen));
    }
    return hasil;
  }

  Future<void> _ambilLokasi() async {
    try {
      final Position posisi = await LocationService.ambilLokasiSaatIni();
      if (!mounted) return;
      setState(() {
        _lokasiSaya = posisi;
        _pesanLokasi = null;
      });
      _ambilNamaKota(posisi);
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _pesanLokasi = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _ambilNamaKota(Position posisi) async {
    try {
      final String kota = await LocationService.ambilNamaKota(
        posisi.latitude,
        posisi.longitude,
      );
      if (!mounted) return;
      setState(() => _namaKota = kota);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pencarianController.dispose();
    _sensorService.berhenti();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<List<ListingModel>> permintaanBaru = _ambilKatalog();
    setState(() {
      _futureListing = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  Future<void> _bukaFilterSheet() async {
    final FilterKatalog? hasil = await tampilkanFilterSheet(
      context: context,
      filterSaatIni: _filter,
    );
    if (hasil != null) {
      setState(() => _filter = hasil);
      _muatUlang();
    }
  }

  void _pilihKategori(String? kategori) {
    setState(() {
      _filter = _filter.copyWith(kategori: () => kategori);
    });
    _muatUlang();
  }

  void _ubahFilter(FilterKatalog filterBaru) {
    setState(() => _filter = filterBaru);
    _muatUlang();
  }

  void _bukaDetail(ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(idListing: listing.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header (Sapaan, Lokasi, Pencarian, Filter & Kategori Chips)
        HeaderKatalog(
          namaPengguna: _namaPengguna,
          adaLokasi: _lokasiSaya != null,
          pesanLokasi: _pesanLokasi,
          namaKota: _namaKota,
          pencarianController: _pencarianController,
          filter: _filter,
          onCari: _muatUlang,
          onHapusCari: () {
            _pencarianController.clear();
            _muatUlang();
          },
          onBukaFilter: _bukaFilterSheet,
          onPilihKategori: _pilihKategori,
        ),

        const SizedBox(height: AppTheme.jarakKecil),

        // 2. Baris Pil Filter Aktif (bisa dihapus satu-satu)
        BarisPilFilterAktif(
          filter: _filter,
          onFilterDiubah: _ubahFilter,
        ),

        // 3. Daftar Listing
        Expanded(
          child: FutureBuilder<List<ListingModel>>(
            future: _futureListing,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final String pesan = snapshot.error
                    .toString()
                    .replaceFirst('Exception: ', '');
                final bool sesiBerakhir = pesan == 'Sesi berakhir';
                return EmptyState(
                  ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
                  pesan: sesiBerakhir
                      ? 'Sesi berakhir, silakan masuk lagi.'
                      : pesan,
                  teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
                  onTombolDitekan: sesiBerakhir
                      ? () => kembaliKeLogin(context)
                      : _muatUlang,
                );
              }

              final List<ListingModel> daftarListing = snapshot.data ?? [];
              final String judulBagian = _filter.urutan == 'nearest'
                  ? 'Rekomendasi Terdekat (${daftarListing.length})'
                  : 'Daftar Produk (${daftarListing.length})';

              final Widget isiDaftar = RefreshIndicator(
                onRefresh: _muatUlang,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.jarakSedang,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.jarakKecil,
                      ),
                      child: Text(
                        judulBagian,
                        style: AppTheme.gayaSubjudul.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (daftarListing.isEmpty) ...[
                      const SizedBox(height: AppTheme.jarakBesar),
                      const EmptyState(
                        ikon: Icons.inventory_2_outlined,
                        pesan:
                            'Tidak ada produk yang cocok dengan filter atau kata kunci',
                      ),
                    ] else
                      ...daftarListing.map((listing) {
                        return ListingCard(
                          listing: listing,
                          onTap: () => _bukaDetail(listing),
                          onHargaTurun: _perbaruiHarga,
                        );
                      }),
                  ],
                ),
              );

              if (!_dataOffline) return isiDaftar;
              return Column(
                children: [
                  const LabelDataOffline(),
                  Expanded(child: isiDaftar),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
