import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/location_service.dart';
import '../../services/sensor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/label_data_offline.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/pilihan_radius.dart';
import '../auth/login_screen.dart';
import 'listing_detail_screen.dart';

// Tab Katalog (pembeli): daftar listing yang sedang dilelang.
// Data: ApiService.ambilDaftarListing() lewat FutureBuilder.
// Berhasil -> disimpan ke Hive (LocalDbService.simpanCacheKatalog).
// Gagal karena server/internet -> tampilkan cache Hive + label "Data offline".
// Lokasi (Modul VII): koordinat HP dikirim ke server -> server mengisi
// distance_km tiap listing dan menyaring sesuai radius yang dipilih.
// setState terjadi saat pencarian dikirim, daftar ditarik ke bawah, HP digoyang,
// atau hitung mundur harga di kartu habis (harga baru diambil dari server).
// -> _futureListing diganti -> FutureBuilder memuat ulang.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController pencarianController = TextEditingController();
  late Future<List<ListingModel>> _futureListing;
  // true bila yang tampil adalah cache Hive (server tidak bisa dihubungi).
  // Diisi di dalam _ambilKatalog, dibaca builder setelah future selesai.
  bool _dataOffline = false;
  Position? _lokasiSaya; // null = lokasi belum didapat
  String? _pesanLokasi; // alasan lokasi gagal (GPS mati, izin ditolak)
  double? _radiusKm; // null = semua jarak
  final SensorService sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _futureListing = _ambilKatalog();
    // Shake-to-refresh: goyang HP = sama dengan tarik ke bawah.
    sensorService.mulaiDeteksiGoyang(_muatUlangKarenaGoyang);
  }

  // Dipanggil kartu saat hitung mundur harga habis: ambil harga baru dari server
  // tanpa spinner (daftar lama tetap tampil sampai data baru datang).
  // Beberapa kartu bisa habis bersamaan, jadi permintaan yang sedang berjalan
  // tidak diulang.
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

  // Fetch dari server; bila gagal, pakai katalog terakhir di Hive.
  Future<List<ListingModel>> _ambilKatalog() async {
    final String kataKunci = pencarianController.text.trim();
    if (_lokasiSaya == null) await _ambilLokasi();
    try {
      final List<ListingModel> daftarListing = await ApiService.ambilDaftarListing(
        kataKunci: kataKunci,
        lat: _lokasiSaya?.latitude,
        lng: _lokasiSaya?.longitude,
        radiusKm: _radiusKm,
      );
      // Cache = katalog lengkap, jadi hanya disimpan bila tanpa kata kunci dan radius.
      if (kataKunci.isEmpty && _radiusKm == null) {
        await LocalDbService.simpanCacheKatalog(daftarListing);
      }
      _dataOffline = false;
      return daftarListing;
    } catch (e) {
      // Sesi berakhir bukan masalah jaringan: tetap tampilkan error-nya.
      if (e.toString().contains('Sesi berakhir')) rethrow;
      final List<ListingModel> cache = LocalDbService.ambilCacheKatalog();
      if (cache.isEmpty) rethrow; // belum pernah online -> tampilkan error
      _dataOffline = true;
      // Pencarian saat offline: saring cache berdasarkan nama atau merek.
      final String kunci = kataKunci.toLowerCase();
      return cache
          .where((listing) =>
              listing.namaProduk.toLowerCase().contains(kunci) ||
              (listing.merek ?? '').toLowerCase().contains(kunci))
          .where((listing) =>
              _radiusKm == null || (listing.jarakKm ?? 0) <= _radiusKm!)
          .toList();
    }
  }

  // Minta lokasi lewat LocationService. Gagal tidak menghentikan katalog:
  // katalog tetap tampil, hanya tanpa jarak.
  Future<void> _ambilLokasi() async {
    try {
      final Position posisi = await LocationService.ambilLokasiSaatIni();
      if (!mounted) return;
      setState(() {
        _lokasiSaya = posisi;
        _pesanLokasi = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _pesanLokasi = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _pilihRadius(double? radius) {
    _radiusKm = radius;
    _muatUlang();
  }

  @override
  void dispose() {
    pencarianController.dispose();
    sensorService.berhenti(); // matikan sensor saat layar ditutup
    super.dispose();
  }

  // Memuat ulang katalog dengan kata kunci saat ini.
  Future<void> _muatUlang() async {
    final Future<List<ListingModel>> permintaanBaru = _ambilKatalog();
    // Pakai kurung kurawal: isi setState tidak boleh mengembalikan Future.
    setState(() {
      _futureListing = permintaanBaru;
    });
    // Ditunggu supaya ikon RefreshIndicator berhenti setelah data datang.
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
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
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.jarakSedang),
          child: TextField(
            controller: pencarianController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _muatUlang(),
            decoration: InputDecoration(
              hintText: 'Cari produk atau merek',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  pencarianController.clear();
                  _muatUlang();
                },
              ),
            ),
          ),
        ),
        PilihanRadius(
          radiusTerpilih: _radiusKm,
          adaLokasi: _lokasiSaya != null,
          pesanLokasi: _pesanLokasi,
          onDipilih: _pilihRadius,
          onAktifkanLokasi: _muatUlang,
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Expanded(
          child: FutureBuilder<List<ListingModel>>(
            future: _futureListing,
            builder: (context, snapshot) {
              // 1. Sedang memuat
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // 2. Gagal
              // Bila 401 ("Sesi berakhir"), tombolnya membawa ke Login
              // (kembaliKeLogin menghapus sesi lalu pushAndRemoveUntil).
              if (snapshot.hasError) {
                final String pesan = snapshot.error.toString().replaceFirst('Exception: ', '');
                final bool sesiBerakhir = pesan == 'Sesi berakhir';
                return EmptyState(
                  ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
                  pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
                  teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
                  onTombolDitekan: sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
                );
              }
              // 3. Berhasil
              final List<ListingModel> daftarListing = snapshot.data ?? [];
              final Widget isiDaftar = RefreshIndicator(
                onRefresh: _muatUlang,
                child: daftarListing.isEmpty
                    ? ListView(
                        // ListView supaya tetap bisa ditarik walau kosong.
                        children: const [
                          SizedBox(height: AppTheme.jarakBesar),
                          EmptyState(
                            ikon: Icons.inventory_2_outlined,
                            pesan: 'Belum ada produk yang sedang dilelang',
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
                        itemCount: daftarListing.length,
                        itemBuilder: (context, indeks) {
                          final ListingModel listing = daftarListing[indeks];
                          return ListingCard(
                            listing: listing,
                            onTap: () => _bukaDetail(listing),
                            onHargaTurun: _perbaruiHarga,
                          );
                        },
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
