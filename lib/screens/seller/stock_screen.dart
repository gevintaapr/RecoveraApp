import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/sensor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kolom_cari.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/pengingat_draft_lokal.dart';
import '../../widgets/tab_segmen.dart';
import '../auth/login_screen.dart';
import 'listing_detail_screen.dart';
import 'upload_invoice_screen.dart';

// Tab Stok (penjual): semua listing milik penjual (T6).
// Data: ApiService.ambilInventaris() lewat FutureBuilder.
// Panel atas: jumlah produk + tombol Upload, kolom cari (saring nama/merek di HP,
// setState tiap mengetik), dan tab segmen status. Draft di HP tampil lewat
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
                          AppTheme.jarakTepi,
                          AppTheme.jarakKecil,
                          AppTheme.jarakTepi,
                          MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang,
                        ),
                        itemCount: daftarStok.length,
                        itemBuilder: (context, indeks) {
                          final ListingModel listing = daftarStok[indeks];
                          return ListingCard(
                            listing: listing,
                            untukPenjual: true,
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

  // Panel putih: jumlah + Upload, kolom cari, tab segmen status (dengan jumlah).
  Widget _panelAtas(List<ListingModel> semuaStok) {
    final List<String?> daftarKunci = _labelStatus.keys.toList();
    final List<String> daftarLabel = daftarKunci
        .map((kunci) => '${_labelStatus[kunci]} ${semuaStok.where((l) => _cocokStatus(l, kunci)).length}')
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(AppTheme.jarakTepi, 0, AppTheme.jarakTepi, AppTheme.jarakSedang),
      decoration: const BoxDecoration(
        color: AppTheme.warnaPermukaan,
        border: Border(bottom: BorderSide(color: AppTheme.warnaGaris)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${semuaStok.length} produk di gudang',
                  style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, AppTheme.tinggiInput)),
                onPressed: () => _bukaHalaman(const UploadInvoiceScreen()),
                icon: const Icon(Icons.add, size: AppTheme.ikonKecil),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          KolomCari(
            controller: _pencarianController,
            petunjuk: 'Cari nama atau merek',
            warnaLatar: AppTheme.warnaLatar,
            onChanged: (_) => setState(() {}),
            onCari: () => setState(() {}),
            onHapus: () {
              _pencarianController.clear();
              setState(() {});
            },
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          TabSegmen(
            daftarLabel: daftarLabel,
            indeksAktif: daftarKunci.indexOf(_filterStatus),
            onPilih: (indeks) => setState(() => _filterStatus = daftarKunci[indeks]),
          ),
        ],
      ),
    );
  }
}
