import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../services/notification_service.dart';
import 'dialog_memuat.dart';

// Tombol "Ingatkan saya" di detail listing (Modul VII, scheduled notification).
// Menjadwalkan pop-up 30 menit sebelum lelang berakhir. Karena dijadwalkan
// oleh Android, pengingat tetap muncul walau aplikasi sudah ditutup.
// setState hanya untuk mengganti teks tombol setelah pengingat dipasang/dibatalkan.
class TombolIngatkan extends StatefulWidget {
  final ListingModel listing;

  const TombolIngatkan({super.key, required this.listing});

  @override
  State<TombolIngatkan> createState() => _TombolIngatkanState();
}

class _TombolIngatkanState extends State<TombolIngatkan> {
  static const Duration jedaSebelumBerakhir = Duration(minutes: 30);
  bool sudahDipasang = false;

  int get _idPengingat => NotificationService.idPengingat(widget.listing.id);

  Future<void> _pasangAtauBatalkan() async {
    final DateTime waktuPengingat =
        widget.listing.lelangBerakhir.subtract(jedaSebelumBerakhir);
    if (!sudahDipasang && waktuPengingat.isBefore(DateTime.now())) {
      _tampilkanPesan('Lelang berakhir kurang dari 30 menit lagi.');
      return;
    }

    tampilkanDialogMemuat(
      context,
      pesan: sudahDipasang ? 'Membatalkan pengingat...' : 'Memasang pengingat...',
    );
    try {
      if (sudahDipasang) {
        await NotificationService().batalkanPengingat(_idPengingat);
      } else {
        await NotificationService().scheduleNotification(
          id: _idPengingat,
          title: 'Lelang segera berakhir',
          body: '${widget.listing.namaProduk} berakhir 30 menit lagi. Cek harganya sekarang!',
          scheduledTime: waktuPengingat,
        );
      }
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      setState(() => sudahDipasang = !sudahDipasang);
      _tampilkanPesan(sudahDipasang
          ? 'Pengingat dipasang pukul ${ListingModel.formatJam(waktuPengingat)}'
          : 'Pengingat dibatalkan');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _tampilkanPesan('Pengingat gagal dipasang');
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _pasangAtauBatalkan,
      icon: Icon(sudahDipasang ? Icons.alarm_on : Icons.alarm_add),
      label: Text(sudahDipasang ? 'Pengingat aktif (ketuk untuk batal)' : 'Ingatkan saya'),
    );
  }
}
