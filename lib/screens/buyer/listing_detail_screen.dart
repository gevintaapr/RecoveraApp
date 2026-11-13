import 'package:flutter/material.dart';

import '../../models/favorit_model.dart';
import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/dialog_beli.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tombol_favorit.dart';
import '../auth/login_screen.dart';
import 'order_detail_screen.dart';

// Detail satu listing (pembeli).
// idListing dikirim lewat konstruktor dari katalog.
// Data: ApiService.ambilDetailListing(idListing) lewat FutureBuilder.
// Tarik ke bawah -> setState mengganti future -> harga terbaru dari server.
class ListingDetailScreen extends StatefulWidget {
  final int idListing;

  const ListingDetailScreen({super.key, required this.idListing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late Future<ListingModel> _futureDetail;

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
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<ListingModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
            child: _IsiDetail(listing: listing),
          );
        },
      ),
    );
  }
}

class _IsiDetail extends StatelessWidget {
  final ListingModel listing;

  const _IsiDetail({required this.listing});

  @override
  Widget build(BuildContext context) {
    final DateTime? turunBerikutnya = listing.waktuTurunBerikutnya;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: (listing.urlGambar == null || listing.urlGambar!.isEmpty)
              ? const _GambarKosong()
              : Image.network(
                  listing.urlGambar!,
                  height: AppTheme.gambarDetail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const _GambarKosong(),
                ),
        ),
        const SizedBox(height: AppTheme.jarakSedang),
        Row(
          children: [
            Expanded(child: Text(listing.namaProduk, style: AppTheme.gayaJudul)),
            TombolFavorit(favorit: FavoritModel.dariListing(listing)),
          ],
        ),
        if (listing.merek != null) Text(listing.merek!, style: AppTheme.gayaTeksRedup),
        const SizedBox(height: AppTheme.jarakSedang),

        // ----- Harga lelang (dari server) -----
        Text('Harga sekarang', style: AppTheme.gayaTeksRedup),
        Row(
          children: [
            Text(ListingModel.formatRupiah(listing.hargaSekarang), style: AppTheme.gayaJudul.copyWith(color: AppTheme.warnaUtama)),
            const SizedBox(width: AppTheme.jarakKecil),
            Text(ListingModel.formatRupiah(listing.hargaNormal), style: AppTheme.gayaHargaCoret),
            const SizedBox(width: AppTheme.jarakKecil),
            if (listing.diskonPersen > 0)
              Text('-${listing.diskonPersen}%',
                  style: const TextStyle(color: AppTheme.warnaAksen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Text(
          turunBerikutnya == null
              ? 'Harga sudah mencapai batas terendah'
              : 'Harga turun lagi pukul ${ListingModel.formatJam(turunBerikutnya)} '
                  '(tarik ke bawah untuk memperbarui)',
          style: AppTheme.gayaTeksRedup,
        ),
        const Divider(height: AppTheme.jarakBesar * 2),

        // ----- Info produk -----
        _BarisInfo(label: 'Stok', nilai: '${listing.stok} ${listing.satuan}'),
        _BarisInfo(label: 'Kategori', nilai: listing.kategori),
        _BarisInfo(label: 'Kedaluwarsa', nilai: ListingModel.formatTanggal(listing.tanggalKedaluwarsa)),
        _BarisInfo(
          label: 'Lelang berakhir',
          nilai: '${ListingModel.formatTanggal(listing.lelangBerakhir)}, ${ListingModel.formatJam(listing.lelangBerakhir)}',
        ),
        _BarisInfo(label: 'Penjual', nilai: listing.namaPenjual ?? '-'),
        _BarisInfo(label: 'Kota gudang', nilai: listing.kotaGudang ?? '-'),
        if (listing.jarakKm != null)
          _BarisInfo(label: 'Jarak', nilai: ListingModel.formatJarak(listing.jarakKm!)),
        const SizedBox(height: AppTheme.jarakBesar),

        PrimaryButton(
          teks: listing.stok > 0 ? 'Beli Sekarang' : 'Stok habis',
          onPressed: listing.stok > 0 ? () => _beli(context) : null, // null = tombol nonaktif
        ),
      ],
    );
  }

  // Alur beli: dialog jumlah -> dialog loading (buffer) -> API -> detail pesanan.
  Future<void> _beli(BuildContext context) async {
    final int? jumlah = await tampilkanDialogBeli(context, listing);
    if (jumlah == null || !context.mounted) return; // dibatalkan

    tampilkanDialogMemuat(context, pesan: 'Memproses pembelian...');
    try {
      final OrderModel pesanan =
          await ApiService.beliSekarang(idListing: listing.id, jumlah: jumlah);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      // (notifikasi "pembelian berhasil" ditambahkan di langkah notifikasi)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian berhasil')),
      );
      // pushReplacement: halaman detail listing diganti detail pesanan,
      // jadi tombol back kembali ke katalog, bukan ke listing yang sudah dibeli.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderDetailScreen(idPesanan: pesanan.id)),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    }
  }
}

class _BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const _BarisInfo({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTheme.gayaTeksRedup)),
          Expanded(flex: 3, child: Text(nilai)),
        ],
      ),
    );
  }
}

class _GambarKosong extends StatelessWidget {
  const _GambarKosong();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppTheme.gambarDetail,
      child: ColoredBox(
        color: AppTheme.warnaGaris,
        child: Center(
          child: Icon(Icons.image_outlined, size: AppTheme.ikonLogo, color: AppTheme.warnaTeksRedup),
        ),
      ),
    );
  }
}
