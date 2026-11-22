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

// Detail satu listing milik penjual (T6).
// - Struktur harga lengkap (normal, mulai lelang, sekarang, minimum).
// - Spesifikasi batch & penyimpanan.
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
    final TextEditingController namaEdit =
        TextEditingController(text: listing.namaProduk);
    final TextEditingController stokEdit =
        TextEditingController(text: '${listing.stok}');
    final TextEditingController hargaNormalEdit =
        TextEditingController(text: listing.hargaNormal.round().toString());
    final TextEditingController hargaMinEdit =
        TextEditingController(text: listing.hargaMinimum.round().toString());
    final TextEditingController batchEdit =
        TextEditingController(text: listing.nomorBatch ?? '');

    final bool? simpan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Isi Draf'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaEdit,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: AppTheme.jarakKecil),
              TextField(
                controller: stokEdit,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Stok (${listing.satuan})'),
              ),
              const SizedBox(height: AppTheme.jarakKecil),
              TextField(
                controller: hargaNormalEdit,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Harga Normal (Rp)'),
              ),
              const SizedBox(height: AppTheme.jarakKecil),
              TextField(
                controller: hargaMinEdit,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Harga Minimum (Rp)'),
              ),
              const SizedBox(height: AppTheme.jarakKecil),
              TextField(
                controller: batchEdit,
                decoration: const InputDecoration(labelText: 'Nomor Batch / Lot'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );

    if (simpan != true || !mounted) return;

    final String nama = namaEdit.text.trim();
    final int? stok = int.tryParse(stokEdit.text);
    final double? hargaNormal = double.tryParse(hargaNormalEdit.text);
    final double? hargaMin = double.tryParse(hargaMinEdit.text);
    final String batch = batchEdit.text.trim();

    if (nama.isEmpty ||
        stok == null ||
        stok <= 0 ||
        hargaNormal == null ||
        hargaNormal <= 0 ||
        hargaMin == null ||
        hargaMin <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom dengan benar')),
      );
      return;
    }

    tampilkanDialogMemuat(context, pesan: 'Memperbarui draf...');
    try {
      await ApiService.ubahDraft(widget.idListing, {
        'name': nama,
        'qty': stok,
        'normal_price': hargaNormal,
        'min_price': hargaMin,
        'batch_number': batch,
      });
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (simpan != true || !mounted) return;

    final int? jumlah = int.tryParse(jumlahController.text);
    final double? hargaMinimum = double.tryParse(hargaMinimumController.text);
    if (jumlah == null || jumlah < 0 || hargaMinimum == null || hargaMinimum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi stok dan harga minimum dengan angka yang benar'),
        ),
      );
      return;
    }

    tampilkanDialogMemuat(context, pesan: 'Menyimpan perubahan...');
    try {
      await ApiService.ubahListing(
        widget.idListing,
        jumlah: jumlah,
        hargaMinimum: hargaMinimum,
      );
      if (!mounted) return;
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Detail Stok')),
      body: FutureBuilder<ListingModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
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
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: AppTheme.jarakSedang),
                Text(listing.namaProduk, style: AppTheme.gayaJudul),
                const SizedBox(height: AppTheme.jarakKecil),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    status: listing.status,
                    label: listing.labelStatus,
                  ),
                ),
                const Divider(height: AppTheme.jarakBesar),

                // Bagian: Struktur Harga (T6)
                _buildStrukturHarga(listing),

                const Divider(height: AppTheme.jarakBesar),

                // Bagian: Spesifikasi Produk & Batch (T6)
                _buildSpesifikasiBatch(listing),

                if (listing.status == 'active' &&
                    listing.waktuTurunBerikutnya != null) ...[
                  const SizedBox(height: AppTheme.jarakSedang),
                  PriceCountdown(
                    waktuTurun: listing.waktuTurunBerikutnya!,
                    onHargaTurun: _muatUlang,
                  ),
                ],
                const SizedBox(height: AppTheme.jarakBesar),

                // Tombol Aksi
                ..._buatAksi(listing),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrukturHarga(ListingModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.payments_outlined, color: AppTheme.warnaUtama, size: 20),
            SizedBox(width: AppTheme.jarakKecil),
            Text('Struktur Harga', style: AppTheme.gayaSubjudul),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        BarisInfo(
          label: 'Harga normal',
          nilai: ListingModel.formatRupiah(listing.hargaNormal),
        ),
        BarisInfo(
          label: 'Harga mulai lelang',
          nilai: ListingModel.formatRupiah(
            listing.hargaMulai ?? listing.hargaSekarang,
          ),
        ),
        if (listing.status == 'active')
          BarisInfo(
            label: 'Harga saat ini',
            nilai: ListingModel.formatRupiah(listing.hargaSekarang),
          ),
        BarisInfo(
          label: 'Batas harga minimum',
          nilai: ListingModel.formatRupiah(listing.hargaMinimum),
        ),
      ],
    );
  }

  Widget _buildSpesifikasiBatch(ListingModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.inventory_outlined, color: AppTheme.warnaUtama, size: 20),
            SizedBox(width: AppTheme.jarakKecil),
            Text('Spesifikasi Batch & Stok', style: AppTheme.gayaSubjudul),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        BarisInfo(label: 'Nomor batch / LOT', nilai: listing.nomorBatch ?? '-'),
        BarisInfo(label: 'Kategori', nilai: listing.kategori),
        BarisInfo(
          label: 'Metode penyimpanan',
          nilai: listing.jenisPenyimpanan ?? 'Suhu Ruang',
        ),
        BarisInfo(label: 'Stok', nilai: '${listing.stok} ${listing.satuan}'),
        BarisInfo(
          label: 'Tanggal kedaluwarsa',
          nilai: ListingModel.formatTanggal(listing.tanggalKedaluwarsa),
        ),
      ],
    );
  }

  List<Widget> _buatAksi(ListingModel listing) {
    if (listing.masihDraft) {
      return [
        if (_saranHarga == null) ...[
          PrimaryButton(
            teks: 'Lihat Rekomendasi Harga',
            sedangMemuat: _sedangMemuatSaran,
            onPressed: _lihatRekomendasi,
          ),
        ] else ...[
          KartuRekomendasiHarga(saran: _saranHarga!, draft: listing),
          const SizedBox(height: AppTheme.jarakSedang),
          PrimaryButton(teks: 'Terbitkan', onPressed: _terbitkan),
        ],
        const SizedBox(height: AppTheme.jarakSedang),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
          onPressed: () => _editDataDraft(listing),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Lanjutkan Upload & Edit Draf'),
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.warnaGalat,
            minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
          ),
          onPressed: _hapusDraft,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Hapus Draf Produk'),
        ),
      ];
    }

    if (listing.status == 'active') {
      return [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
          onPressed: () => _ubahStokDanHarga(listing),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Ubah Stok / Harga Minimum'),
        ),
      ];
    }

    return [
      Text(
        listing.status == 'sold'
            ? 'Stok sudah habis terjual.'
            : 'Lelang sudah berakhir.',
        style: AppTheme.gayaTeksRedup,
      ),
    ];
  }
}
