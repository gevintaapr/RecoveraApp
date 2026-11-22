import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/favorit_model.dart';
import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bar_bawah_beli.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_faktur_sukses.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/dialog_pin_transaksi.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notifikasi_glass.dart';
import '../../widgets/price_countdown.dart';
import '../../widgets/sheet_konfirmasi_beli.dart';
import '../../widgets/tombol_favorit.dart';
import '../../widgets/tombol_ingatkan.dart';
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
          appBar: AppBar(title: const Text('Detail Produk')),
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
              child: _IsiDetail(listing: listing!, onHargaTurun: _muatUlang),
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

class _IsiDetail extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const _IsiDetail({required this.listing, required this.onHargaTurun});

  double? get _jarakKeGudang {
    if (listing.jarakKm != null) return listing.jarakKm;
    final Position? lokasi = LocationService.lokasiTerakhir;
    if (lokasi == null || listing.latGudang == null || listing.lngGudang == null) {
      return null;
    }
    return LocationService.hitungJarakKm(
      lokasi.latitude,
      lokasi.longitude,
      listing.latGudang!,
      listing.lngGudang!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? turunBerikutnya = listing.waktuTurunBerikutnya;
    final double? jarakKeGudang = _jarakKeGudang;

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
        const Text('Harga sekarang', style: AppTheme.gayaTeksRedup),
        Row(
          children: [
            Text(
              ListingModel.formatRupiah(listing.hargaSekarang),
              style: AppTheme.gayaJudul.copyWith(color: AppTheme.warnaUtama),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Text(
              ListingModel.formatRupiah(listing.hargaNormal),
              style: AppTheme.gayaHargaCoret,
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            if (listing.diskonPersen > 0)
              Text(
                '-${listing.diskonPersen}%',
                style: const TextStyle(
                  color: AppTheme.warnaAksen,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        if (turunBerikutnya == null)
          const Text('Harga sudah mencapai batas terendah', style: AppTheme.gayaTeksRedup)
        else ...[
          const SizedBox(height: AppTheme.jarakKecil),
          PriceCountdown(waktuTurun: turunBerikutnya, onHargaTurun: onHargaTurun),
          const SizedBox(height: AppTheme.jarakKecil / 2),
          Text(
            'Batas terendah: ${ListingModel.formatRupiah(listing.hargaMinimum)}',
            style: AppTheme.gayaTeksRedup,
          ),
        ],
        const Divider(height: AppTheme.jarakBesar * 2),

        // ----- Spesifikasi Batch & Info Produk (T1) -----
        BarisInfo(label: 'Stok', nilai: '${listing.stok} ${listing.satuan}'),
        BarisInfo(label: 'Nomor batch', nilai: listing.nomorBatch ?? '-'),
        BarisInfo(label: 'Penyimpanan', nilai: listing.jenisPenyimpanan ?? '-'),
        const BarisInfo(label: 'Metode pengambilan', nilai: 'Ambil di gudang'),
        BarisInfo(label: 'Kategori', nilai: listing.kategori),
        BarisInfo(
          label: 'Kedaluwarsa',
          nilai: ListingModel.formatTanggal(listing.tanggalKedaluwarsa),
        ),
        BarisInfo(
          label: 'Lelang berakhir',
          nilai:
              '${ListingModel.formatTanggal(listing.lelangBerakhir)}, ${ListingModel.formatJam(listing.lelangBerakhir)}',
        ),
        BarisInfo(label: 'Penjual', nilai: listing.namaPenjual ?? '-'),
        BarisInfo(label: 'Kota gudang', nilai: listing.kotaGudang ?? '-'),
        if (jarakKeGudang != null)
          BarisInfo(label: 'Jarak ke gudang', nilai: ListingModel.formatJarak(jarakKeGudang)),
        const SizedBox(height: AppTheme.jarakSedang),
        TombolIngatkan(favorit: FavoritModel.dariListing(listing)),
      ],
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
