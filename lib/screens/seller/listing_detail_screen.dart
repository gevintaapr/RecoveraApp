import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/price_advice_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_rekomendasi_harga.dart';
import '../../widgets/price_countdown.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

// Detail satu listing milik penjual. idListing dikirim dari halaman Stok.
// Data: ApiService.ambilDetailListing(idListing) lewat FutureBuilder.
// - Draft  : "Lihat Rekomendasi Harga" -> setState menampilkan kartu saran
//            -> "Terbitkan" -> kembali ke Stok (Navigator.pop).
// - Aktif  : "Ubah Stok / Harga Minimum" -> dialog -> ApiService.ubahListing
//            -> _muatUlang (setState mengganti future).
class SellerListingDetailScreen extends StatefulWidget {
  final int idListing;

  const SellerListingDetailScreen({super.key, required this.idListing});

  @override
  State<SellerListingDetailScreen> createState() => _SellerListingDetailScreenState();
}

class _SellerListingDetailScreenState extends State<SellerListingDetailScreen> {
  late Future<ListingModel> _futureDetail;
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController hargaMinimumController = TextEditingController();
  bool _sedangMemuatSaran = false;
  PriceAdviceModel? _saranHarga;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService.ambilDetailListing(widget.idListing);
  }

  @override
  void dispose() {
    jumlahController.dispose();
    hargaMinimumController.dispose();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<ListingModel> permintaanBaru = ApiService.ambilDetailListing(widget.idListing);
    setState(() {
      _futureDetail = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _tampilkanGalat(Object e) async {
    if (!mounted) return;
    final String pesan = e.toString().replaceFirst('Exception: ', '');
    if (pesan == 'Sesi berakhir') {
      await kembaliKeLogin(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _lihatRekomendasi() async {
    setState(() => _sedangMemuatSaran = true);
    try {
      final PriceAdviceModel saran = await ApiService.ambilRekomendasiHarga(widget.idListing);
      if (!mounted) return;
      setState(() => _saranHarga = saran);
    } catch (e) {
      await _tampilkanGalat(e);
    } finally {
      if (mounted) setState(() => _sedangMemuatSaran = false);
    }
  }

  Future<void> _terbitkan() async {
    try {
      final bool berhasil = await terbitkanDenganKonfirmasi(
        context,
        idListing: widget.idListing,
        saran: _saranHarga!,
      );
      if (!berhasil || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing berhasil diterbitkan')),
      );
      Navigator.pop(context); // kembali ke Stok, yang lalu memuat ulang
    } catch (e) {
      await _tampilkanGalat(e);
    }
  }

  Future<void> _ubahStokDanHarga(ListingModel listing) async {
    jumlahController.text = '${listing.stok}';
    hargaMinimumController.text = listing.hargaMinimum.round().toString();
    final bool? simpan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Stok / Harga Minimum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Stok (${listing.satuan})'),
            ),
            const SizedBox(height: AppTheme.jarakSedang),
            TextField(
              controller: hargaMinimumController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga minimum (Rp)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (simpan != true || !mounted) return;

    final int? jumlah = int.tryParse(jumlahController.text);
    final double? hargaMinimum = double.tryParse(hargaMinimumController.text);
    if (jumlah == null || jumlah < 0 || hargaMinimum == null || hargaMinimum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi stok dan harga minimum dengan angka yang benar')),
      );
      return;
    }

    tampilkanDialogMemuat(context, pesan: 'Menyimpan perubahan...');
    try {
      await ApiService.ubahListing(widget.idListing, jumlah: jumlah, hargaMinimum: hargaMinimum);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
      await _muatUlang();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      await _tampilkanGalat(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Stok')),
      body: FutureBuilder<ListingModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              ikon: Icons.error_outline,
              pesan: snapshot.error.toString().replaceFirst('Exception: ', ''),
              teksTombol: 'Coba lagi',
              onTombolDitekan: _muatUlang,
            );
          }
          final ListingModel listing = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.jarakSedang),
              children: [
                if (listing.urlGambar != null && listing.urlGambar!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Image.network(
                      listing.urlGambar!,
                      height: AppTheme.gambarDetail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: AppTheme.jarakSedang),
                Text(listing.namaProduk, style: AppTheme.gayaJudul),
                const SizedBox(height: AppTheme.jarakKecil),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(status: listing.status, label: listing.labelStatus),
                ),
                const Divider(height: AppTheme.jarakBesar * 2),
                if (listing.status == 'active')
                  BarisInfo(label: 'Harga sekarang', nilai: ListingModel.formatRupiah(listing.hargaSekarang)),
                BarisInfo(label: 'Harga normal', nilai: ListingModel.formatRupiah(listing.hargaNormal)),
                BarisInfo(label: 'Harga minimum', nilai: ListingModel.formatRupiah(listing.hargaMinimum)),
                BarisInfo(label: 'Stok', nilai: '${listing.stok} ${listing.satuan}'),
                BarisInfo(label: 'Kategori', nilai: listing.kategori),
                BarisInfo(label: 'Kedaluwarsa', nilai: ListingModel.formatTanggal(listing.tanggalKedaluwarsa)),
                if (listing.status == 'active' && listing.waktuTurunBerikutnya != null) ...[
                  const SizedBox(height: AppTheme.jarakSedang),
                  PriceCountdown(waktuTurun: listing.waktuTurunBerikutnya!, onHargaTurun: _muatUlang),
                ],
                const SizedBox(height: AppTheme.jarakBesar),
                ..._buatAksi(listing),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tombol yang tampil tergantung status listing.
  List<Widget> _buatAksi(ListingModel listing) {
    if (listing.masihDraft) {
      if (_saranHarga == null) {
        return [
          PrimaryButton(
            teks: 'Lihat Rekomendasi Harga',
            sedangMemuat: _sedangMemuatSaran,
            onPressed: _lihatRekomendasi,
          ),
        ];
      }
      return [
        KartuRekomendasiHarga(saran: _saranHarga!, draft: listing),
        const SizedBox(height: AppTheme.jarakSedang),
        PrimaryButton(teks: 'Terbitkan', onPressed: _terbitkan),
      ];
    }
    if (listing.status == 'active') {
      return [
        OutlinedButton.icon(
          onPressed: () => _ubahStokDanHarga(listing),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Ubah Stok / Harga Minimum'),
        ),
      ];
    }
    return [
      Text(
        listing.status == 'sold' ? 'Stok sudah habis terjual.' : 'Lelang sudah berakhir.',
        style: AppTheme.gayaTeksRedup,
      ),
    ];
  }
}
