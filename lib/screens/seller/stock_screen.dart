import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/draft_listing_model.dart';
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

// Tab Stok (penjual): semua listing milik penjual (T6).
// Menampilkan kolom pencarian stok (saring nama/merek di HP),
// chip status dengan jumlah item, dan daftar stok.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  static const Map<String?, String> _labelStatus = {
    null: 'Semua',
    'draft': 'Draft',
    'active': 'Aktif',
    'sold': 'Habis',
    'expired': 'Kedaluwarsa',
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
    final Future<List<ListingModel>> permintaanBaru =
        ApiService.ambilInventaris();
    setState(() {
      _futureStok = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  List<ListingModel> _saring(List<ListingModel> semua) {
    final String kunci = _pencarianController.text.trim().toLowerCase();

    return semua.where((listing) {
      // Saring status
      bool cocokStatus = true;
      if (_filterStatus != null) {
        if (_filterStatus == 'draft') {
          cocokStatus = listing.masihDraft;
        } else {
          cocokStatus = listing.status == _filterStatus;
        }
      }

      // Saring kata kunci pencarian
      bool cocokKataKunci = true;
      if (kunci.isNotEmpty) {
        final String nama = listing.namaProduk.toLowerCase();
        final String merek = (listing.merek ?? '').toLowerCase();
        cocokKataKunci = nama.contains(kunci) || merek.contains(kunci);
      }

      return cocokStatus && cocokKataKunci;
    }).toList();
  }

  Future<void> _bukaHalaman(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => halaman),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaHalaman(const UploadInvoiceScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Upload Stok'),
      ),
      body: FutureBuilder<List<ListingModel>>(
        future: _futureStok,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final String pesan =
                snapshot.error.toString().replaceFirst('Exception: ', '');
            final bool sesiBerakhir = pesan == 'Sesi berakhir';
            return EmptyState(
              ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
              pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
              teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
              onTombolDitekan:
                  sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
            );
          }

          final List<ListingModel> semuaStok = snapshot.data ?? [];
          final List<ListingModel> daftarStok = _saring(semuaStok);

          return Column(
            children: [
              // Pengingat Draft Lokal bila ada di Hive
              _PengingatDraftLokal(
                onTap: () => _bukaHalaman(const UploadInvoiceScreen()),
              ),

              // Kolom Pencarian Stok
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.jarakSedang,
                  vertical: AppTheme.jarakKecil / 2,
                ),
                child: TextField(
                  controller: _pencarianController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari stok produk atau merek...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _pencarianController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _pencarianController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.jarakSedang,
                      vertical: AppTheme.jarakKecil,
                    ),
                  ),
                ),
              ),

              // Chip Status Horizontal dengan Counter
              _buatChipFilter(semuaStok),

              const SizedBox(height: AppTheme.jarakKecil),

              // Daftar Stok
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _muatUlang,
                  child: daftarStok.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: AppTheme.jarakBesar),
                            EmptyState(
                              ikon: Icons.inventory_2_outlined,
                              pesan:
                                  'Tidak ada stok yang cocok dengan filter atau kata kunci.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.jarakSedang,
                            0,
                            AppTheme.jarakSedang,
                            AppTheme.ikonLogo,
                          ),
                          itemCount: daftarStok.length,
                          itemBuilder: (context, indeks) {
                            final ListingModel listing = daftarStok[indeks];
                            return ListingCard(
                              listing: listing,
                              untukPenjual: true,
                              onTap: () => _bukaHalaman(
                                SellerListingDetailScreen(idListing: listing.id),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buatChipFilter(List<ListingModel> semuaStok) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: Row(
        children: _labelStatus.entries.map((entry) {
          final String? statusKey = entry.key;
          final int jumlah = statusKey == null
              ? semuaStok.length
              : (statusKey == 'draft'
                  ? semuaStok.where((l) => l.masihDraft).length
                  : semuaStok.where((l) => l.status == statusKey).length);
          final String label = '${entry.value} ($jumlah)';
          final bool isSelected = _filterStatus == statusKey;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.jarakKecil),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppTheme.warnaUtama.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                fontSize: AppTheme.fontKecil,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.warnaUtama : AppTheme.warnaTeks,
              ),
              backgroundColor: AppTheme.warnaPermukaan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                side: BorderSide(
                  color: isSelected ? AppTheme.warnaUtama : AppTheme.warnaGaris,
                ),
              ),
              onSelected: (_) => setState(() => _filterStatus = statusKey),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PengingatDraftLokal extends StatelessWidget {
  final VoidCallback onTap;

  const _PengingatDraftLokal({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DraftListingModel>>(
      valueListenable: LocalDbService.pantauDraft(),
      builder: (context, Box<DraftListingModel> box, child) {
        if (box.isEmpty) return const SizedBox.shrink();
        final int jumlah = box.length;
        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppTheme.jarakSedang,
            AppTheme.jarakKecil,
            AppTheme.jarakSedang,
            AppTheme.jarakKecil / 2,
          ),
          decoration: BoxDecoration(
            color: AppTheme.warnaAksen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: AppTheme.warnaAksen.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(
              Icons.drafts_outlined,
              color: AppTheme.warnaAksen,
            ),
            title: Text(
              '$jumlah draft produk tersimpan di HP',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppTheme.fontNormal,
              ),
            ),
            subtitle: const Text(
              'Ketuk untuk melanjutkan upload',
              style: TextStyle(fontSize: AppTheme.fontKecil),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.warnaAksen,
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
