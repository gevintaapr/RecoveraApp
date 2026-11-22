import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

// NotifikasiController (GetX, Modul VIII): jumlah notifikasi belum dibaca.
// Angka ini tampil sebagai badge di ikon lonceng AppBar (Obx), dan ikut
// berkurang saat notifikasi dibaca di halaman Notifikasi -- tanpa setState
// dan tanpa mengoper data antar layar.
// Didaftarkan dengan Get.put di main.dart.
class NotifikasiController extends GetxController {
  final RxInt jumlahBelumDibaca = 0.obs;

  // Cek inbox server: munculkan pop-up untuk yang baru (lewat NotificationService),
  // lalu perbarui badge. Error dilempar ke pemanggil.
  Future<List<NotificationModel>> muatUlang() async {
    final List<NotificationModel> daftarNotif =
        await NotificationService().checkNewNotifications();
    jumlahBelumDibaca.value =
        daftarNotif.where((notif) => !notif.sudahDibaca).length;
    return daftarNotif;
  }

  // Dipanggil MainShell di latar belakang: gagal (offline, sesi habis) cukup diabaikan,
  // nanti dicoba lagi pada pemicu berikutnya.
  Future<void> cekDiLatar() async {
    try {
      await muatUlang();
    } catch (_) {
      // sengaja diabaikan
    }
  }

  Future<void> tandaiDibaca(NotificationModel notif) async {
    if (notif.sudahDibaca) return;
    await ApiService.tandaiNotifikasiDibaca(notif.id);
    if (jumlahBelumDibaca.value > 0) jumlahBelumDibaca.value--;
  }

  // Dipanggil saat logout supaya badge akun berikutnya mulai dari nol.
  void kosongkan() {
    jumlahBelumDibaca.value = 0;
  }
}
