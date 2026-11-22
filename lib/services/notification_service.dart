import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_model.dart';
import '../screens/buyer/listing_detail_screen.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../screens/seller/listing_detail_screen.dart';
import 'api_service.dart';
import 'session_service.dart';

// NotificationService (Modul VII): pop-up notifikasi lokal.
// Tiga sumber pop-up:
// 1. Aksi sendiri (beli berhasil)        -> showInstantNotification
// 2. "Ingatkan saya" sebelum lelang usai -> scheduleNotification
// 3. Inbox server (pesanan masuk, dll.)  -> checkNewNotifications
//
// Mendukung navigasi otomatis saat pop-up di status bar diketuk (T8).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'recovera_channel_v2';
  static const String channelName = 'Notifikasi Recovera';

  static int idBeliBerhasil(int idPesanan) => 1000000 + idPesanan;
  static int idPengingat(int idListing) => 2000000 + idListing;
  static int idListingTerbit(int idListing) => 3000000 + idListing;

  bool get _didukung =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // Dipanggil sekali di main.dart sebelum runApp.
  Future<void> init() async {
    if (!_didukung) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await notificationPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _tanganiResponsNotifikasi,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        notificationPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.requestNotificationsPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Pesanan, lelang, dan pengingat',
      importance: Importance.max,
    );
    await androidPlatform?.createNotificationChannel(channel);
  }

  // CATATAN: Navigasi payload pop-up status bar (elemen di luar modul)
  // Fungsi: membuka layar detail pesanan atau produk saat pop-up status bar diketuk.
  // Cara kerja: saat notifikasi ditampilkan, payload teks "order:ID" atau "listing:ID" disertakan.
  // Ketika pengguna mengetuk notifikasi, handler ini membaca payload dan
  // melakukan navigasi menggunakan Get.to dari GetMaterialApp.
  static void _tanganiResponsNotifikasi(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final List<String> bagian = payload.split(':');
    if (bagian.length < 2) return;

    final String tipe = bagian[0];
    final int? id = int.tryParse(bagian[1]);
    if (id == null) return;

    final String? peran = await SessionService.ambilPeran();
    final bool isPenjual = peran == 'seller';

    if (tipe == 'order') {
      Get.to(() => OrderDetailScreen(idPesanan: id, isPenjual: isPenjual));
    } else if (tipe == 'listing') {
      if (isPenjual) {
        Get.to(() => SellerListingDetailScreen(idListing: id));
      } else {
        Get.to(() => ListingDetailScreen(idListing: id));
      }
    }
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
    String? payload,
  }) async {
    if (!_didukung) return;
    await notificationPlugin.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: _buatDetail(),
    );
  }

  // 2. Pop-up terjadwal.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_didukung) return;
    final tz.TZDateTime waktu = tz.TZDateTime.from(scheduledTime, tz.local);
    try {
      await notificationPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        payload: payload,
        scheduledDate: waktu,
        notificationDetails: _buatDetail(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      await notificationPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        payload: payload,
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

  // 3. Jembatan inbox server -> pop-up lokal.
  Future<List<NotificationModel>> checkNewNotifications() async {
    final List<NotificationModel> daftarNotif =
        await ApiService.ambilNotifikasi();
    final int? idTerakhir = await SessionService.ambilIdNotifTerakhir();

    int idTerbesar = idTerakhir ?? 0;
    for (final NotificationModel notif in daftarNotif) {
      if (idTerakhir != null && notif.id > idTerakhir && !notif.sudahDibaca) {
        String? payload;
        if (notif.idPesanan != null) {
          payload = 'order:${notif.idPesanan}';
        } else if (notif.idListing != null) {
          payload = 'listing:${notif.idListing}';
        }

        await showInstantNotification(
          id: notif.id,
          title: notif.judul,
          body: notif.isi,
          payload: payload,
        );
      }
      if (notif.id > idTerbesar) idTerbesar = notif.id;
    }
    await SessionService.simpanIdNotifTerakhir(idTerbesar);
    return daftarNotif;
  }
}
