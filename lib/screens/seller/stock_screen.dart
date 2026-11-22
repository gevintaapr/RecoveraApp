import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/sensor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chip_filter_status.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kolom_cari.dart';
import '../../widgets/kartu_stok_penjual.dart';
import '../../widgets/pengingat_draft_lokal.dart';
import '../auth/login_screen.dart';
import 'listing_detail_screen.dart';
import 'upload_invoice_screen.dart';

// Tab Stok (penjual): semua listing milik penjual (T6).
// Data: ApiService.ambilInventaris() lewat FutureBuilder.
// Bagian atas: "Stok Saya" + tombol Upload, kolom cari (saring nama/merek di HP,
// setState tiap mengetik), dan chip status. Draft di HP tampil lewat
// ValueListenableBuilder (Hive).
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  static const Map<String?, String> _labelStatus = {
    null: 'Semua',
    'active': 'Aktif',
    'draft': 'Draft',
    'sold': 'Habis',
    'expired': 'Lewat',
  };

  final TextEditingController _pencarianController = TextEditingController();
  late Future<List<ListingModel>> _futureStok;
  String? _filterStatus;
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _futureStok = ApiService.ambilInventaris();
    _sensorService.mulaiDeteksiGoyang(_muatUlangKarenaGoyang);
  }

  @override
  void dispose() {
    _pencarianController.dispose();
    _sensorService.berhenti();
    super.dispose();
  }

  void _muatUlangKarenaGoyang() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('HP digoyang, memuat ulang stok...')),
    );
    _muatUlang();
  }

  Future<void> _muatUlang() async {
    final Future<List<ListingModel>> permintaanBaru = ApiService.ambilInventaris();
    setState(() {
      _futureStok = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  bool _cocokStatus(ListingModel listing, String? status) {
    if (status == null) return true;
    if (status == 'draft') return listing.masihDraft;
    return listing.status == status;
  }

  List<ListingModel> _saring(List<ListingModel> semua) {
    final String kunci = _pencarianController.text.trim().toLowerCase();
    return semua.where((listing) {
      final bool cocokKataKunci = kunci.isEmpty ||
          listing.namaProduk.toLowerCase().contains(kunci) ||
          (listing.merek ?? '').toLowerCase().contains(kunci);
      return _cocokStatus(listing, _filterStatus) && cocokKataKunci;
    }).toList();
  }

  Future<void> _bukaHalaman(Widget halaman) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => halaman));
    if (!mounted) return;
    await _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListingModel>>(
      future: _futureStok,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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

        final List<ListingModel> semuaStok = snapshot.data ?? [];
        final List<ListingModel> daftarStok = _saring(semuaStok);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelAtas(semuaStok),
            PengingatDraftLokal(onTap: () => _bukaHalaman(const UploadInvoiceScreen())),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _muatUlang,
                child: daftarStok.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: AppTheme.jarakBesar),
                          EmptyState(
                            ikon: Icons.inventory_2_outlined,
                            pesan: 'Tidak ada stok yang cocok.\nUbah kata kunci atau pilih status lain.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        // Jarak bawah = tinggi bar navigasi kaca (extendBody) + jarak biasa.
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.jarakBesar,
                          AppTheme.jarakKecil,
                          AppTheme.jarakBesar,
                          MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang,
                        ),
                        itemCount: daftarStok.length,
                        itemBuilder: (context, indeks) {
                          final ListingModel listing = daftarStok[indeks];
                          return KartuStokPenjual(
                            listing: listing,
                            onTap: () => _bukaHalaman(SellerListingDetailScreen(idListing: listing.id)),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Bagian atas (Stok Saya Recovera lama): judul + pil jumlah stok aktif + tombol
  // Upload, kolom cari, dan chip status (dengan jumlah). Tanpa panel putih.
  Widget _panelAtas(List<ListingModel> semuaStok) {
    final List<String?> daftarKunci = _labelStatus.keys.toList();
    final List<String> daftarLabel = daftarKunci
        .map((kunci) => '${_labelStatus[kunci]} (${semuaStok.where((l) => _cocokStatus(l, kunci)).length})')
        .toList();
    final int jumlahAktif = semuaStok.where((l) => l.status == 'active').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.jarakBesar, AppTheme.jarakTepi, AppTheme.jarakBesar, AppTheme.jarakSedang),
          child: Row(
            children: [
              const Text(
                'Stok Saya',
                style: TextStyle(fontSize: AppTheme.fontJudulStok, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy, letterSpacing: -0.5),
              ),
              const SizedBox(width: AppTheme.radiusSedang),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.radiusSedang, vertical: AppTheme.jarakMini),
                  decoration: BoxDecoration(color: AppTheme.warnaLatarInfo, borderRadius: BorderRadius.circular(AppTheme.radiusKapsul)),
                  child: Text(
                    '$jumlahAktif stok aktif',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w700, color: AppTheme.warnaJarak),
                  ),
                ),
              ),
              const Spacer(),
              // Tombol Upload stok (di versi lama berupa FAB "Upload Stok").
              Material(
                color: AppTheme.warnaUtama,
                borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
                  onTap: () => _bukaHalaman(const UploadInvoiceScreen()),
                  child: const SizedBox(
                    width: AppTheme.ukuranTombolIkon,
                    height: AppTheme.ukuranTombolIkon,
                    child: Tooltip(
                      message: 'Upload Stok',
                      child: Icon(Icons.add_a_photo_outlined, color: AppTheme.warnaPermukaan, size: AppTheme.ikonSedang),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar),
          child: KolomCari(
            controller: _pencarianController,
            petunjuk: 'Cari stok...',
            onChanged: (_) => setState(() {}),
            onCari: () => setState(() {}),
            onHapus: () {
              _pencarianController.clear();
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: AppTheme.jarakSedang),
        ChipFilterStatus(
          daftarLabel: daftarLabel,
          indeksAktif: daftarKunci.indexOf(_filterStatus),
          onPilih: (indeks) => setState(() => _filterStatus = daftarKunci[indeks]),
        ),
        const SizedBox(height: AppTheme.jarakKecil),
      ],
    );
  }
}
