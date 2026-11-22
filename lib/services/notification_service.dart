import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_model.dart';
import 'api_service.dart';
import 'session_service.dart';

// NotificationService (Modul VII): pop-up notifikasi lokal.
// Tiga sumber pop-up, semuanya lewat class ini:
// 1. Aksi sendiri (beli berhasil)        -> showInstantNotification
// 2. "Ingatkan saya" sebelum lelang usai -> scheduleNotification (tetap muncul walau aplikasi ditutup)
// 3. Inbox server (pesanan masuk, dll.)  -> checkNewNotifications
//
// Pola singleton seperti di Modul VII: NotificationService() selalu
// mengembalikan objek yang sama, jadi plugin cukup di-init sekali di main.dart.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // ID channel diberi akhiran _v2: pengaturan channel Android (importance)
  // tidak bisa diubah setelah channel dibuat. Ganti ID = channel baru.
  static const String channelId = 'recovera_channel_v2';
  static const String channelName = 'Notifikasi Recovera';

  // ID notifikasi harus unik, kalau tidak notifikasi baru menimpa yang lama.
  // Dibuat rentang terpisah agar tiga sumber tidak saling bentrok:
  //   inbox server : id notifikasi server apa adanya (1, 2, 3, ...)
  //   beli berhasil: 1.000.000 + id pesanan
  //   pengingat    : 2.000.000 + id listing
  //   listing terbit: 3.000.000 + id listing
  static int idBeliBerhasil(int idPesanan) => 1000000 + idPesanan;
  static int idPengingat(int idListing) => 2000000 + idListing;
  static int idListingTerbit(int idListing) => 3000000 + idListing;

  // Pop-up hanya disiapkan untuk Android (target demo). Saat aplikasi dijalankan
  // di Chrome / Windows untuk uji tampilan, semua method di bawah diam saja.
  bool get _didukung => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // Dipanggil sekali di main.dart sebelum runApp.
  Future<void> init() async {
    if (!_didukung) return;
    // CATATAN: Menggunakan timezone (elemen di luar modul)
    // Fungsi: menyediakan zona waktu untuk notifikasi terjadwal.
    // Alasan: zonedSchedule pada flutter_local_notifications wajib memakai TZDateTime.
    // Cara kerja: muat data semua zona waktu, lalu tetapkan zona lokal ke Asia/Jakarta (WIB).
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await notificationPlugin.initialize(settings: initSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        notificationPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // Android 13+ wajib meminta izin notifikasi ke pengguna.
    await androidPlatform?.requestNotificationsPermission();

    // Importance.max agar Android menampilkan pop-up di atas layar (heads-up).
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Pesanan, lelang, dan pengingat',
      importance: Importance.max,
    );
    await androidPlatform?.createNotificationChannel(channel);
  }

  NotificationDetails _buatDetail() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // 1. Pop-up langsung.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_didukung) return;
    await notificationPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _buatDetail(),
    );
  }

  // 2. Pop-up terjadwal. Dijadwalkan oleh Android, jadi tetap muncul
  //    walau aplikasi ditutup.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_didukung) return;
    final tz.TZDateTime waktu = tz.TZDateTime.from(scheduledTime, tz.local);
    try {
      // Tepat waktu. Butuh izin "Alarm & pengingat" (Android 12+).
      await notificationPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: waktu,
        notificationDetails: _buatDetail(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Izin alarm tepat belum diberikan (default di Android 14):
      // tetap dijadwalkan, hanya bisa mundur beberapa menit.
      await notificationPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: waktu,
        notificationDetails: _buatDetail(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> batalkanPengingat(int id) async {
    if (!_didukung) return;
    await notificationPlugin.cancel(id: id);
  }

  // 3. Jembatan inbox server -> pop-up lokal (tanpa FCM, tanpa Timer).
  // Ambil GET /notifications, munculkan pop-up untuk notifikasi yang ID-nya
  // lebih besar dari ID terakhir yang pernah dilihat (last_notif_id).
  // Mengembalikan daftar notifikasi supaya pemanggil bisa menghitung badge.
  Future<List<NotificationModel>> checkNewNotifications() async {
    final List<NotificationModel> daftarNotif = await ApiService.ambilNotifikasi();
    final int? idTerakhir = await SessionService.ambilIdNotifTerakhir();

    int idTerbesar = idTerakhir ?? 0;
    for (final NotificationModel notif in daftarNotif) {
      // idTerakhir == null: pengecekan pertama setelah login.
      // Notifikasi lama tidak di-pop-up, cukup dicatat ID terbesarnya.
      if (idTerakhir != null && notif.id > idTerakhir && !notif.sudahDibaca) {
        await showInstantNotification(id: notif.id, title: notif.judul, body: notif.isi);
      }
      if (notif.id > idTerbesar) idTerbesar = notif.id;
    }
    await SessionService.simpanIdNotifTerakhir(idTerbesar);
    return daftarNotif;
  }
}
