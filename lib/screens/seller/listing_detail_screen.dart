import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/price_advice_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/aksi_detail_stok.dart';
import '../../widgets/dialog_edit_draft.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/dialog_ubah_stok.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/isi_detail_stok.dart';
import '../../widgets/kartu_rekomendasi_harga.dart';
import '../../widgets/tombol_kembali.dart';
import '../auth/login_screen.dart';

// Detail satu listing milik penjual (T6), tampilan Detail Produk Recovera lama.
// Data: ApiService.ambilDetailListing lewat FutureBuilder; isi di IsiDetailStok,
// tombol di AksiDetailStok, form di DialogEditDraft / DialogUbahStok.
// - Draft: Lihat Rekomendasi, Edit Draft, Hapus Draft, Terbitkan.
// - Aktif: Ubah Stok / Harga Minimum.
class SellerListingDetailScreen extends StatefulWidget {
  final int idListing;

  const SellerListingDetailScreen({super.key, required this.idListing});

  @override
  State<SellerListingDetailScreen> createState() =>
      _SellerListingDetailScreenState();
}

class _SellerListingDetailScreenState extends State<SellerListingDetailScreen> {
  late Future<ListingModel> _futureDetail;
  bool _sedangMemuatSaran = false;
  PriceAdviceModel? _saranHarga;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService.ambilDetailListing(widget.idListing);
  }

  Future<void> _muatUlang() async {
    final Future<ListingModel> permintaanBaru =
        ApiService.ambilDetailListing(widget.idListing);
    setState(() {
      _futureDetail = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  Future<void> _tampilkanGalat(Object e) async {
    if (!mounted) return;
    final String pesan = e.toString().replaceFirst('Exception: ', '');
    if (pesan == 'Sesi berakhir') {
      await kembaliKeLogin(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: AppTheme.warnaGalat,
      ),
    );
  }

  Future<void> _lihatRekomendasi() async {
    setState(() => _sedangMemuatSaran = true);
    try {
      final PriceAdviceModel saran =
          await ApiService.ambilRekomendasiHarga(widget.idListing);
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
      Navigator.pop(context);
    } catch (e) {
      await _tampilkanGalat(e);
    }
  }

  Future<void> _hapusDraft() async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Draf Produk'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus draf produk ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.warnaGalat,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Menghapus draf...');
    try {
      await ApiService.hapusDraft(widget.idListing);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draf berhasil dihapus')),
      );
      Navigator.pop(context); // kembali ke daftar stok
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _tampilkanGalat(e);
    }
  }

  Future<void> _editDataDraft(ListingModel listing) async {
    final Map<String, dynamic>? data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogEditDraft(listing: listing),
    );
    if (data == null || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Memperbarui draf...');
    try {
      await ApiService.ubahDraft(widget.idListing, data);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan draf berhasil disimpan')),
      );
      setState(() => _saranHarga = null);
      await _muatUlang();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _tampilkanGalat(e);
    }
  }

  Future<void> _ubahStokDanHarga(ListingModel listing) async {
    final Map<String, dynamic>? data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogUbahStok(listing: listing),
    );
    if (data == null || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Menyimpan perubahan...');
    try {
      await ApiService.ubahListing(
        widget.idListing,
        jumlah: data['jumlah'] as int,
        hargaMinimum: data['hargaMinimum'] as double,
      );
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan')),
      );
      await _muatUlang();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _tampilkanGalat(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar terang seperti Detail Produk Recovera lama; back selalu tampil.
      appBar: AppBar(
        backgroundColor: AppTheme.warnaLatar,
        foregroundColor: AppTheme.warnaNavy,
        leading: const TombolKembali(),
        // Gaya judul ditulis langsung: titleTextStyle tema berwarna putih.
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontSize: AppTheme.fontJudulTransaksi, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(AppTheme.jarakBesar, AppTheme.jarakSedang, AppTheme.jarakBesar, AppTheme.jarakBawahHalaman),
              children: [
                IsiDetailStok(listing: listing, onHargaTurun: _muatUlang),
                const SizedBox(height: AppTheme.jarakAuthSisi),
                AksiDetailStok(
                  listing: listing,
                  saranHarga: _saranHarga,
                  sedangMemuatSaran: _sedangMemuatSaran,
                  onLihatRekomendasi: _lihatRekomendasi,
                  onTerbitkan: _terbitkan,
                  onEditDraft: () => _editDataDraft(listing),
                  onHapusDraft: _hapusDraft,
                  onUbahStok: () => _ubahStokDanHarga(listing),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
