import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/sensor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../auth/login_screen.dart';
import 'listing_detail_screen.dart';
import 'upload_invoice_screen.dart';

// Tab Stok (penjual): semua listing milik penjual.
// Data: ApiService.ambilInventaris() lewat FutureBuilder.
// setState terjadi saat:
// - chip status dipilih (filter di HP, tanpa request baru);
// - ditarik ke bawah, HP digoyang, atau kembali dari detail/upload -> future diganti.
// Tombol "Upload Stok" membuka alur upload faktur.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  // null = semua status
  static const Map<String?, String> _pilihanFilter = {
    null: 'Semua',
    'draft': 'Draft',
    'active': 'Aktif',
    'sold': 'Habis',
    'expired': 'Kedaluwarsa',
  };

  late Future<List<ListingModel>> _futureStok;
  String? _filterStatus;
  final SensorService sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _futureStok = ApiService.ambilInventaris();
    // Shake-to-refresh: goyang HP = sama dengan tarik ke bawah.
    sensorService.mulaiDeteksiGoyang(_muatUlangKarenaGoyang);
  }

  @override
  void dispose() {
    sensorService.berhenti(); // matikan sensor saat layar ditutup
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
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  // "draft" juga mencakup "review" (draft yang sudah lengkap, siap terbit).
  List<ListingModel> _saring(List<ListingModel> semua) {
    if (_filterStatus == null) return semua;
    if (_filterStatus == 'draft') return semua.where((l) => l.masihDraft).toList();
    return semua.where((l) => l.status == _filterStatus).toList();
  }

  Future<void> _bukaHalaman(Widget halaman) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => halaman));
    if (!mounted) return;
    await _muatUlang(); // stok bisa berubah setelah terbit / diubah
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaHalaman(const UploadInvoiceScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Upload Stok'),
      ),
      body: Column(
        children: [
          _PengingatDraftLokal(onTap: () => _bukaHalaman(const UploadInvoiceScreen())),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
            child: Row(
              children: _pilihanFilter.entries
                  .map((pilihan) => Padding(
                        padding: const EdgeInsets.only(right: AppTheme.jarakKecil),
                        child: ChoiceChip(
                          label: Text(pilihan.value),
                          selected: _filterStatus == pilihan.key,
                          onSelected: (_) => setState(() => _filterStatus = pilihan.key),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(child: _buatDaftar()),
        ],
      ),
    );
  }

  Widget _buatDaftar() {
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
        final List<ListingModel> daftarStok = _saring(snapshot.data ?? []);
        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: daftarStok.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: AppTheme.jarakBesar),
                    EmptyState(
                      ikon: Icons.inventory_2_outlined,
                      pesan: 'Belum ada stok. Tekan "Upload Stok" untuk menambah.',
                    ),
                  ],
                )
              : ListView.builder(
                  // Ruang bawah agar kartu terakhir tidak tertutup tombol Upload.
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.jarakSedang, AppTheme.jarakKecil, AppTheme.jarakSedang, AppTheme.ikonLogo,
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
        );
      },
    );
  }
}

// Baris pengingat bila ada draft yang masih tersimpan di HP (Hive).
// ValueListenableBuilder: jumlahnya ikut berubah saat draft disimpan/dihapus.
class _PengingatDraftLokal extends StatelessWidget {
  final VoidCallback onTap;

  const _PengingatDraftLokal({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalDbService.pantauDraft(),
      builder: (context, box, child) {
        final int jumlahDraft = LocalDbService.ambilSemuaDraft().length;
        if (jumlahDraft == 0) return const SizedBox(height: AppTheme.jarakKecil);
        return Card(
          margin: const EdgeInsets.all(AppTheme.jarakSedang),
          child: ListTile(
            leading: const Icon(Icons.edit_note, color: AppTheme.warnaAksen),
            title: Text('$jumlahDraft draft tersimpan di HP'),
            subtitle: const Text('Belum dikirim ke server. Ketuk untuk melanjutkan.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
