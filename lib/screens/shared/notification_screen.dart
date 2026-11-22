import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notifikasi_controller.dart';
import '../../models/notification_model.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../auth/login_screen.dart';
import '../buyer/listing_detail_screen.dart';
import '../buyer/order_detail_screen.dart';
import '../seller/listing_detail_screen.dart';

// Halaman Notifikasi (kedua peran), dibuka dari ikon lonceng di AppBar (T8).
// Menampilkan waktu relatif dan membuka halaman yang sesuai dengan jenis notifikasi.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotifikasiController notifikasiController =
      Get.find<NotifikasiController>();
  late Future<List<NotificationModel>> _futureNotifikasi;

  @override
  void initState() {
    super.initState();
    _futureNotifikasi = notifikasiController.muatUlang();
  }

  Future<void> _muatUlang() async {
    final Future<List<NotificationModel>> permintaanBaru =
        notifikasiController.muatUlang();
    setState(() {
      _futureNotifikasi = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  Future<void> _bukaNotifikasi(NotificationModel notif) async {
    if (!notif.sudahDibaca) {
      tampilkanDialogMemuat(context, pesan: 'Membuka notifikasi...');
      try {
        await notifikasiController.tandaiDibaca(notif);
        if (!mounted) return;
        Navigator.pop(context); // tutup dialog loading
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.warnaGalat,
          ),
        );
        return;
      }
    }
    if (!mounted) return;

    final String? peran = await SessionService.ambilPeran();
    final bool isPenjual = peran == 'seller';
    if (!mounted) return;

    // Navigasi sesuai jenis notifikasi (T8)
    if (notif.idPesanan != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(
            idPesanan: notif.idPesanan!,
            isPenjual: isPenjual,
          ),
        ),
      );
      if (!mounted) return;
    } else if (notif.idListing != null) {
      if (isPenjual) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerListingDetailScreen(
              idListing: notif.idListing!,
            ),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(
              idListing: notif.idListing!,
            ),
          ),
        );
      }
      if (!mounted) return;
    }

    _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _futureNotifikasi,
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
          final List<NotificationModel> daftarNotif = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: daftarNotif.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: AppTheme.jarakBesar),
                      EmptyState(
                        ikon: Icons.notifications_none,
                        pesan: 'Belum ada notifikasi',
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: daftarNotif.length,
                    separatorBuilder: (context, indeks) =>
                        const Divider(height: 1),
                    itemBuilder: (context, indeks) {
                      final NotificationModel notif = daftarNotif[indeks];
                      return _ItemNotifikasi(
                        notif: notif,
                        onTap: () => _bukaNotifikasi(notif),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _ItemNotifikasi extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _ItemNotifikasi({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: notif.sudahDibaca ? null : AppTheme.warnaPermukaan,
      leading: Icon(
        notif.idPesanan != null
            ? Icons.receipt_long_outlined
            : (notif.idListing != null
                ? Icons.inventory_2_outlined
                : Icons.notifications_outlined),
        color:
            notif.sudahDibaca ? AppTheme.warnaTeksRedup : AppTheme.warnaUtama,
      ),
      title: Text(
        notif.judul,
        style: TextStyle(
          fontWeight: notif.sudahDibaca ? FontWeight.normal : FontWeight.bold,
          color: AppTheme.warnaTeks,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notif.isi,
            style: const TextStyle(
              fontSize: AppTheme.fontNormal,
              color: AppTheme.warnaTeksRedup,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notif.waktuRelatif,
            style: TextStyle(
              fontSize: AppTheme.fontKecil,
              fontWeight:
                  notif.sudahDibaca ? FontWeight.normal : FontWeight.w600,
              color: notif.sudahDibaca
                  ? AppTheme.warnaTeksRedup
                  : AppTheme.warnaUtama,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: notif.sudahDibaca
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.warnaUtama,
              ),
            ),
      onTap: onTap,
    );
  }
}
