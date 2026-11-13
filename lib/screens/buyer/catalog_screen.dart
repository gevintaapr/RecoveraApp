import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

// Tab Katalog (pembeli): daftar listing yang sedang dilelang.
// Data: ApiService.ambilDaftarListing() lewat FutureBuilder.
// setState terjadi saat pencarian dikirim atau daftar ditarik ke bawah
// -> _futureListing diganti -> FutureBuilder memuat ulang.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController pencarianController = TextEditingController();
  late Future<List<ListingModel>> _futureListing;

  @override
  void initState() {
    super.initState();
    _futureListing = ApiService.ambilDaftarListing();
  }

  @override
  void dispose() {
    pencarianController.dispose();
    super.dispose();
  }

  // Memuat ulang katalog dengan kata kunci saat ini.
  Future<void> _muatUlang() async {
    final Future<List<ListingModel>> permintaanBaru =
        ApiService.ambilDaftarListing(kataKunci: pencarianController.text.trim());
    setState(() => _futureListing = permintaanBaru);
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
        Expanded(
          child: FutureBuilder<List<ListingModel>>(
            future: _futureListing,
            builder: (context, snapshot) {
              // 1. Sedang memuat
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // 2. Gagal
              if (snapshot.hasError) {
                return EmptyState(
                  ikon: Icons.wifi_off,
                  pesan: snapshot.error.toString().replaceFirst('Exception: ', ''),
                  teksTombol: 'Coba lagi',
                  onTombolDitekan: _muatUlang,
                );
              }
              // 3. Berhasil
              final List<ListingModel> daftarListing = snapshot.data ?? [];
              return RefreshIndicator(
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
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
