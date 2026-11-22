import 'package:flutter/material.dart';

import '../../models/favorit_model.dart';
import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bar_bawah_beli.dart';
import '../../widgets/dialog_faktur_sukses.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/dialog_pin_transaksi.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/isi_detail_listing.dart';
import '../../widgets/notifikasi_glass.dart';
import '../../widgets/sheet_konfirmasi_beli.dart';
import '../../widgets/tombol_favorit.dart';
import '../auth/login_screen.dart';
import 'order_detail_screen.dart';

// Detail satu listing (pembeli) - T1.
// idListing dikirim lewat konstruktor dari katalog.
// Bar bawah tetap (Sticky Bottom Bar) menyediakan stepper jumlah dan Beli Sekarang.
class ListingDetailScreen extends StatefulWidget {
  final int idListing;

  const ListingDetailScreen({super.key, required this.idListing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late Future<ListingModel> _futureDetail;
  int _jumlahBeli = 1;

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
      // Error ditangani oleh FutureBuilder.
    }
  }

  // Alur T1: Stepper -> Konfirmasi Bottom Sheet -> Loading -> API -> Faktur Sukses.
  Future<void> _prosesBeli(ListingModel listing) async {
    final bool? konfirmasi = await tampilkanSheetKonfirmasiBeli(
      context: context,
      listing: listing,
      jumlah: _jumlahBeli,
    );
    if (konfirmasi != true || !mounted) return;

    // Verifikasi PIN Transaksi (Pengganti Biometrik)
    final bool? pinValid = await tampilkanDialogPinTransaksi(context);
    if (pinValid != true || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Memproses pembelian...');
    try {
      final OrderModel pesanan = await ApiService.beliSekarang(
        idListing: listing.id,
        jumlah: _jumlahBeli,
      );
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading

      // Pop-up notifikasi langsung pembelian (Modul VII).
      await NotificationService().showInstantNotification(
        id: NotificationService.idBeliBerhasil(pesanan.id),
        title: 'Pembelian berhasil',
        body: '${pesanan.jumlah} ${listing.satuan} ${listing.namaProduk} '
            '- total ${ListingModel.formatRupiah(pesanan.totalHarga)}',
      );

      // Beberapa detik setelah pembelian: notifikasi bahwa pesanan diproses penjual & reminder
      Future.delayed(const Duration(seconds: 3), () async {
        await NotificationService().showInstantNotification(
          id: 3000000 + pesanan.id,
          title: 'Pesanan Akan Diproses Penjual',
          body: 'Penjual sedang menyiapkan pesanan Anda. Anda dapat mengirim pengingat setiap 3 menit.',
        );
        tampilkanNotifikasiGlass(
          judul: 'Pesanan Akan Diproses Penjual',
          pesan: 'Penjual sedang menyiapkan pesanan Anda. Anda dapat mengirim pengingat setiap 3 menit.',
          ikon: Icons.notifications_active_outlined,
          warnaIkon: AppTheme.warnaUtama,
          durasi: const Duration(seconds: 4),
        );
      });

      if (!mounted) return;
      // Faktur ringkas setelah sukses
      await tampilkanDialogFakturSukses(
        context: context,
        pesanan: pesanan,
        listing: listing,
        onLihatPesanan: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(idPesanan: pesanan.id),
            ),
          );
        },
      );
      _muatUlang(); // Perbarui sisa stok
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      tampilkanNotifikasiGlass(pesan: pesan, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListingModel>(
      future: _futureDetail,
      builder: (context, snapshot) {
        final ListingModel? listing = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.warnaPermukaan,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listing != null)
                  Text(
                    [
                      if (listing.nomorBatch != null) 'Batch ${listing.nomorBatch}',
                      listing.kategori,
                    ].join(' · ').toUpperCase(),
                    style: AppTheme.gayaLabelKapital,
                  ),
                const Text('Detail produk'),
              ],
            ),
            actions: [
              if (listing != null) TombolFavorit(favorit: FavoritModel.dariListing(listing)),
              const SizedBox(width: AppTheme.jarakKecil),
            ],
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting && listing == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final String pesan = snapshot.error.toString().replaceFirst('Exception: ', '');
              final bool sesiBerakhir = pesan == 'Sesi berakhir';
              return EmptyState(
                ikon: sesiBerakhir ? Icons.lock_outline : Icons.error_outline,
                pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
                teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
                onTombolDitekan: sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
              );
            }
            return RefreshIndicator(
              onRefresh: _muatUlang,
              child: IsiDetailListing(listing: listing!, onHargaTurun: _muatUlang),
            );
          }(),
          bottomNavigationBar: listing == null
              ? null
              : BarBawahBeli(
                  listing: listing,
                  jumlah: _jumlahBeli,
                  onJumlahDiubah: (nilai) => setState(() => _jumlahBeli = nilai),
                  onBeliDitekan: () => _prosesBeli(listing),
                ),
        );
      },
    );
  }
}
