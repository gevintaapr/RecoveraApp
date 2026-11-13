# Panduan Proyek Akhir PAM — Recovera Versi Praktikum

Nov 8, 2026 · @gepi

## 1. Keputusan Final

| Topik | Keputusan |
| --- | --- |
| Tema | **Recovera**, disederhanakan untuk praktikum |
| Patokan | Ketentuan TA = minimal menerapkan materi modul. Fitur di luar modul dibuang, **kecuali** yang menjadi nilai inti aplikasi: AI (OCR + rekomendasi harga) dan harga turun otomatis. |
| Backend | **FastAPI tetap dipakai.** Flutter cukup memanggil REST API dengan `http`, sama persis dengan pola Modul V. |
| Peran | **Tetap 2: Penjual & Pembeli** |
| AI | Gemini OCR faktur (dipanggil dari backend) + rekomendasi harga **LightGBM dengan fallback rumus** |
| Dibuang | Sertifikat ESG + SHA-256/blockchain, kompas magnetometer, biometrik, Saran & Kesan, FCM, konversi mata uang & waktu |
| Mini game | **Tetap**, tapi versi sederhana supaya kodenya mudah dijelaskan (Bagian 5) |
| Dokumen acuan | PRD, schema, backend contract, dan endpoint coverage tetap jadi pegangan. Yang belum diperbarui dicatat di Bagian 9. |

## 2. Materi Modul → Bukti di Recovera

Tabel ini adalah "kriteria wajib" versi praktikum. Ini **menggantikan** daftar 14 kriteria di sprint plan, karena daftar itu untuk tugas teori.

| Modul | Yang harus bisa ditunjuk di kode |
| --- | --- |
| I – Setup | `void main() async` → `WidgetsFlutterBinding.ensureInitialized()` → init Hive, init notifikasi, cek sesi → `runApp` |
| II – Widget | Katalog dengan `GridView`/`ListView.builder` + `Card`; form listing dengan `TextFormField`; kartu harga dan countdown |
| III – State & Data | `StatefulWidget` + `setState`; `TextEditingController` + `dispose()` di form register dan listing; model `Listing.fromJson` |
| IV – Navigation | Login → `pushReplacement` ke shell sesuai peran; Logout → `pushAndRemoveUntil`; katalog → detail (kirim objek listing lewat konstruktor); `BottomNavigationBar` dengan `_pages` berbeda per peran |
| V – HTTP | `ApiService` static: `POST /auth/login`, `GET /listings`, `GET /listings/{id}`, `POST /listings/{id}/buy`; alur Fetch → Parse → Render + loading; header `Authorization: Bearer` |
| VI – Local Storage | **SharedPreferences**: token, peran, nama, `isLoggedIn`. **Hive**: cache katalog, cache pesanan, draft listing, skor game; `ValueListenableBuilder` untuk draft dan skor |
| VII – Notif & LBS | `geolocator`: lokasi pembeli untuk filter radius dan jarak ke gudang, lokasi gudang saat seller register. Notifikasi **immediate** (pembelian berhasil, listing terbit) dan **scheduled** ("Ingatkan saya" 30 menit sebelum lelang berakhir) |
| Sensor | Akselerometer untuk shake-to-refresh + mini game (`sensors_plus`, elemen asing, wajib diberi komentar) |

## 3. Fitur Final per Peran

### 3.1 Fitur bersama

| Fitur | Status | Catatan |
| --- | --- | --- |
| Splash + cek sesi | Tetap | Baca `isLoggedIn` dan peran dari SharedPreferences |
| Register (pilih peran) | Tetap | Seller wajib kirim `company_name` (bug 422 sudah diperbaiki). Lokasi gudang diisi lewat tombol **"Gunakan lokasi saat ini"** (geolocator), bukan peta pin picker. |
| Login | Tetap | Access token disimpan di SharedPreferences |
| Refresh token otomatis | **Dibuang dari Flutter** | Kalau dapat 401: hapus sesi → kembali ke Login dengan pesan "Sesi berakhir". Endpoint `/auth/refresh` tetap ada di backend, hanya tidak dipanggil. |
| Profil + Logout | Tetap | `GET /profile`. Logout jadi tombol di Profil dengan dialog konfirmasi (bukan tab). Memanggil `POST /auth/logout` tanpa body, lalu hapus sesi lokal. |
| Inbox notifikasi | Tetap | Ikon lonceng di AppBar: `GET /notifications`, `PATCH /notifications/{id}/read` |
| Local notification | Tetap | Pengganti FCM (Modul VII) |
| Mini game | Tetap (disederhanakan) | Bagian 5 |
| Biometrik, Saran & Kesan, FCM, ESG/blockchain, kompas, peta OSM | **Dibuang** | Di luar modul. Jarak ke gudang cukup ditampilkan sebagai teks "2,4 km". |
| Konversi mata uang & waktu | **Dibuang** | Tidak ada di modul. Kalau mau menambah nilai, endpoint `/rates` sudah tersedia. |

### 3.2 Penjual — tab: Dasbor · Stok · Game · Profil

| Fitur | Endpoint | Catatan |
| --- | --- | --- |
| Dasbor | `GET /listings/my`, `GET /orders` | Ringkasan: listing aktif, terjual, pesanan yang perlu diproses |
| Daftar stok + draft | `GET /listings/seller/inventory` |  |
| Upload langkah 1: foto faktur | `POST /ai/invoice` (multipart) | Hasil OCR mengisi form otomatis. Kalau OCR gagal, form manual tetap terbuka. |
| Upload langkah 2: data + harga | `POST …/inventory/drafts` → `POST …/{id}/recommendation` → `POST …/{id}/publish` | Kartu rekomendasi harga dari LightGBM, dengan fallback rumus |
| Draft offline | Hive | Disimpan lokal, lalu diterbitkan **manual** lewat tombol "Terbitkan". Auto-sync dibuang. |
| Edit / tarik listing | `PATCH /listings/{id}` |  |
| Alihkan ke donasi | `PATCH /listings/{id}` (status `diverted`) | Cukup ubah status, tanpa sertifikat |
| Pesanan masuk + tandai diambil | `GET /orders`, `PATCH /orders/{id}/status` | `paid` → `picked_up` → `completed` |

### 3.3 Pembeli — tab: Katalog · Pesanan · Game · Profil

| Fitur | Endpoint | Catatan |
| --- | --- | --- |
| Katalog + cari + filter + sort | `GET /listings?search&category&lat&lng&radius_km&sort` | Kalau offline, tampilkan cache dari Hive dengan label "Data offline" |
| Shake-to-refresh | — | Akselerometer memicu ambil ulang katalog |
| Detail listing | `GET /listings/{id}` | Harga sekarang, countdown ke `next_drop_at`, jarak ke gudang, tombol **"Ingatkan saya"** (notifikasi terjadwal) |
| Beli Sekarang | `POST /listings/{id}/buy` | Dialog konfirmasi biasa (pengganti biometrik), lalu notifikasi "Pembelian berhasil" |
| Riwayat + detail pesanan | `GET /orders`, `GET /orders/{id}` | Info gudang + jarak, tombol "Tandai sudah diambil" |

Total sekitar **15 layar**: 7 bersama (splash, login, register, profil, notifikasi, pesanan, game), 5 penjual, 3 pembeli (+ filter berupa bottom sheet). Layar pesanan dipakai bersama oleh penjual dan pembeli; tombol aksinya mengikuti peran.

### 3.4 Notifikasi Pop-up (Heads-up)

**Kenapa dulu tidak muncul sebagai pop-up:** notifikasi di Recovera lama hanya berupa data dari `GET /notifications` yang ditampilkan di halaman notifikasi. Sistem notifikasi Android tidak pernah dipanggil (`.show()`), karena FCM tidak pernah disambungkan (PBI-22 masih To Do dan `/devices` belum dipakai). Jadi datanya ada, tapi tidak pernah "dilempar" ke status bar.

**Solusinya: tiga sumber pop-up, semuanya pakai `flutter_local_notifications` (Modul VII):**

| Sumber | Kapan | Cara |
| --- | --- | --- |
| Aksi sendiri | Setelah beli berhasil, setelah listing terbit | Panggil `showInstantNotification()` langsung setelah response sukses |
| Pengingat | "Ingatkan saya" 30 menit sebelum lelang berakhir | `scheduleNotification()`. **Tetap muncul walau aplikasi ditutup.** |
| Dari server (pesanan masuk, harga turun) | Saat aplikasi dibuka dan saat halaman notifikasi di-refresh | Cek `GET /notifications` sekali saat MainShell dibuka, lalu setiap halaman Notifikasi dibuka atau ditarik ke bawah (RefreshIndicator, Modul V). Notifikasi yang ID-nya baru dimunculkan sebagai pop-up. Tanpa Timer, jadi lebih mudah dijelaskan. |

> **Batasan yang harus jujur disebut saat presentasi:** notifikasi dari server hanya bisa pop-up saat aplikasi dibuka atau halaman notifikasi di-refresh, jadi tidak real-time. Kalau aplikasi ditutup total, butuh FCM (push), dan FCM sengaja tidak dipakai karena di luar modul. Pengingat terjadwal tetap jalan walau aplikasi ditutup.

#### a. `services/notification_service.dart` (dari Modul VII, dengan 3 perubahan)

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // PERUBAHAN 1: ID channel baru ("_v2").
  // Importance sebuah channel Android TIDAK BISA diubah setelah channel dibuat.
  // Kalau channel lama sudah terlanjur dibuat dengan importance rendah,
  // notifikasi tidak akan pop-up walaupun kodenya sudah diganti.
  // Mengganti ID = Android membuat channel baru dengan pengaturan terbaru.
  static const String channelId = 'recovera_channel_v2';
  static const String channelName = 'Notifikasi Recovera';

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await notificationPlugin.initialize(initSettings);

    final androidPlatform = notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.requestNotificationsPermission();

    // PERUBAHAN 2: Importance.max agar Android menampilkan pop-up di atas layar.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Pesanan, lelang, dan pengingat',
      importance: Importance.max,
    );
    await androidPlatform?.createNotificationChannel(channel);
  }

  NotificationDetails _buildDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // PERUBAHAN 3: id dijadikan parameter.
  // Di modul id selalu 0, akibatnya notifikasi baru MENIMPA notifikasi lama.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationPlugin.show(id, title, body, _buildDetails());
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime(tz.local, scheduledTime.year, scheduledTime.month,
          scheduledTime.day, scheduledTime.hour, scheduledTime.minute),
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
```

#### b. `services/notification_service.dart` — tambah satu method (jembatan inbox → pop-up, tanpa file baru)

```dart
// ===== Tambahkan di notification_service.dart =====
// 1) Import di bagian atas file:
//    import 'package:shared_preferences/shared_preferences.dart';
//    import '../models/notification_model.dart';
//    import 'api_service.dart';
//
// 2) Method ini DI DALAM class NotificationService (di bawah scheduleNotification):

  // Mengambil inbox dari server, lalu memunculkan pop-up untuk notifikasi
  // yang ID-nya lebih besar dari ID terakhir yang sudah pernah dilihat.
  Future<void> checkNewNotifications() async {
    try {
      final List<NotificationModel> daftarNotif =
          await ApiService.fetchNotifications();
      if (daftarNotif.isEmpty) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? lastSeenId = prefs.getInt('last_notif_id');

      int idTerbesar = lastSeenId ?? 0;
      for (final NotificationModel notif in daftarNotif) {
        // lastSeenId == null artinya pengecekan pertama setelah login:
        // jangan munculkan semua notifikasi lama, cukup catat ID terbesarnya.
        if (lastSeenId != null && notif.id > lastSeenId && !notif.isRead) {
          await showInstantNotification(
            id: notif.id,
            title: notif.title,
            body: notif.body,
          );
        }
        if (notif.id > idTerbesar) idTerbesar = notif.id;
      }
      await prefs.setInt('last_notif_id', idTerbesar);
    } catch (e) {
      // Pengecekan ini berjalan di latar. Kalau jaringan gagal, cukup diabaikan
      // dan dicoba lagi pada pemicu berikutnya; tidak perlu menampilkan error.
    }
  }
```

**Jangan lupa:** hapus `last_notif_id` saat logout, supaya akun lain yang login di HP yang sama tidak kebanjiran atau malah kehilangan pop-up.

#### c. Dua pemicu sederhana (tanpa Timer) di `screens/shared/main_shell.dart`

```dart
// Pemicu 1 — screens/shared/main_shell.dart
// Cek SEKALI saat shell pertama kali dibuka. Memakai initState (Modul III),
// tanpa Timer dan tanpa observer.
@override
void initState() {
  super.initState();
  NotificationService().checkNewNotifications();
}

// Pemicu 2 — screens/shared/notification_screen.dart
// Cek setiap halaman dibuka dan setiap ditarik ke bawah.
// RefreshIndicator sama seperti contoh pull-to-refresh di Modul V.
Future<void> loadNotifications() async {
  try {
    await NotificationService().checkNewNotifications(); // pop-up jika ada yang baru
    final List<NotificationModel> result = await ApiService.fetchNotifications();
    if (!mounted) return;
    setState(() {
      daftarNotif = result;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    // tampilkan SnackBar seperti pola loadUsers() di modul
  }
}
// body: RefreshIndicator(onRefresh: loadNotifications, child: ListView.builder(...))
```

**Kenapa tanpa Timer?** Versi sebelumnya mengecek tiap 30 detik dengan `Timer.periodic` dan `WidgetsBindingObserver`. Keduanya di luar modul dan harus kamu jelaskan sendiri. Versi ini cukup memakai `initState` dan `RefreshIndicator` yang sudah diajarkan. Harganya: pop-up dari server tidak real-time. Kalau kelak mau real-time (Tingkat 2), tambahkan `Timer.periodic` di `main_shell.dart` dengan komentar elemen asing; yang dipanggil tetap `checkNewNotifications()`.

#### d. Checklist kalau pop-up masih tidak muncul

1. **Izin notifikasi** sudah diizinkan (Android 13+ meminta izin saat `init()`). Cek di Pengaturan → Aplikasi → Recovera → Notifikasi.
2. **Channel lama**: uninstall aplikasi sekali, atau pastikan ID channel sudah diganti (perubahan 1).
3. **HP Xiaomi / Oppo / Vivo / Realme** sering mematikan "notifikasi mengambang / pop-up" per aplikasi secara default. Aktifkan manual di pengaturan notifikasi aplikasi.
4. **Mode Jangan Ganggu** sedang mati.
5. **AndroidManifest** sudah berisi `POST_NOTIFICATIONS`, izin exact alarm, dan receiver sesuai Modul VII (wajib untuk notifikasi terjadwal).
6. **ID notifikasi unik.** Kalau semua ID 0, yang terlihat hanya notifikasi terakhir.

**Opsional:** buka halaman notifikasi saat pop-up diketuk, lewat `onDidReceiveNotificationResponse` + `navigatorKey`. Ini elemen asing, jadi kerjakan hanya kalau waktu masih ada.

### 3.5 Prioritas Pengerjaan: Tingkat 1 dan Tingkat 2

Kerjakan Tingkat 1 sampai tuntas dan bisa didemokan sebelum menyentuh Tingkat 2. Kalau waktu habis, aplikasi tetap utuh dan semua materi modul tetap terbukti.

| Tingkat | Fitur | Bukti modul / catatan |
| --- | --- | --- |
| 1 (wajib) | Splash, login, register, sesi, shell per peran, logout | Modul I, III, IV; SharedPreferences (VI) |
| 1 (wajib) | Katalog, detail, Beli Sekarang, pesanan; cache katalog + draft listing di Hive | Modul II, V, VI (`ValueListenableBuilder` untuk draft) |
| 1 (wajib) | Penjual: upload faktur (OCR) → rekomendasi harga → terbitkan; stok; pesanan masuk | Modul III (form), V (multipart: beri komentar) |
| 1 (wajib) | Lokasi: jarak ke gudang, filter radius, lokasi gudang saat register | Modul VII (`geolocator`) |
| 1 (wajib) | Notifikasi immediate + scheduled ("Ingatkan saya") + inbox lonceng | Modul VII |
| 1 (wajib) | Sensor: shake-to-refresh versi terkecil (±15 baris) | Ada di tabel Bagian 2. Cek ke asisten atau Modul VII apakah sensor wajib; kalau tidak, turunkan ke Tingkat 2 |
| 2 (kalau waktu ada, urut) | 1. Pop-up notifikasi dari server (`checkNewNotifications`) | Bagian 3.4 |
| 2 (kalau waktu ada, urut) | 2. Mini game "Food Saver Challenge" (versi tombol) + skor di Hive | Bagian 5 |
| 2 (kalau waktu ada, urut) | 3. Filter lanjutan (bottom sheet) + sort | Modul II; pencarian dasar tetap di Tingkat 1 |
| 2 (kalau waktu ada, urut) | 4. Ketuk pop-up membuka halaman tujuan; Timer real-time | Elemen asing, wajib komentar |

**Aturan 1 menit per layar:** tiap layar harus bisa kamu jelaskan dalam satu menit tanpa membuka file lain: layar ini menampilkan apa, datanya dari method `ApiService` yang mana, dan `setState` terjadi kapan. Layar yang tidak lolos harus dipotong atau digabung. Latih dengan lima layar terpenting: login, katalog, detail, upload faktur, notifikasi.

**Yang berubah dari draf sebelumnya:**

| Aspek | Sebelumnya | Sekarang |
| --- | --- | --- |
| File service | 10 | 6 (`ApiService` tunggal) |
| Layar | 16 | 15 (layar pesanan digabung); game dan filter jadi Tingkat 2 |
| Notifikasi dari server | `Timer.periodic` + `WidgetsBindingObserver` + file sync terpisah | `initState` + `RefreshIndicator`, satu method di `notification_service.dart` |
| Cakupan | Semua fitur setara | Dibagi Tingkat 1 dan 2 |

**Yang sengaja tidak dipotong:** dua peran dan OCR + LightGBM, karena kamu memutuskan mempertahankannya dan logika beratnya ada di backend. Risikonya ada di waktu pengerjaan dua peran. Kalau waktu mepet, selesaikan satu peran (pembeli) sampai tuntas dulu, baru lengkapi penjual.

## 4. Backend: Endpoint yang Dipakai

**Dipakai Flutter:** `/auth/register`, `/auth/login`, `/auth/logout`, `GET /profile`, `GET /listings`, `GET /listings/{id}`, `POST /listings/{id}/buy`, `GET /listings/my`, `PATCH /listings/{id}`, seluruh `/listings/seller/inventory/*`, `POST /ai/invoice`, `GET /orders`, `GET /orders/{id}`, `PATCH /orders/{id}/status`, `GET /notifications`, `PATCH /notifications/{id}/read`.

**Tidak dipanggil Flutter, tapi biarkan di backend** (jangan dihapus supaya tidak merusak yang sudah jalan): `/auth/refresh`, `PATCH /profile`, `/products`, `POST /listings` (sudah digantikan alur draft), `/ai/price-advice`, `/donations/*`, `/blockchain/verify/*`, `/rates`, `/devices`, `/feedback`.

> **Pilih satu endpoint harga.** `/ai/price-advice` dan `/inventory/{id}/recommendation` tumpang tindih. Pakai `recommendation` karena sudah terikat ke listing, dan pastikan LightGBM + fallback ada di endpoint itu.

### LightGBM: syarat aman saat presentasi

1. **Bisa menjelaskan dalam dua kalimat:** input (sisa hari kedaluwarsa, kategori, harga normal, …), output (persen diskon awal), dan data latihnya (data seed).
2. **Fallback rumus** pakai aturan di PRD US-06: sisa umur >90 hari diskon 25%, 60–90 hari 30%, 30–60 hari 40%, 15–30 hari 50%, <15 hari 55%. Harga tidak pernah di bawah `min_price`.
3. **Saran ke backend:** tambahkan field `source: "model" | "rule"` di response, supaya UI bisa menampilkan "Rekomendasi AI" atau "Rekomendasi aturan". Ini jujur dan sekaligus jadi bukti fallback-nya bekerja.

Semua response memakai amplop `{success, data}` / `{success, error{code, message}}`. `ApiService` cukup membaca `error.message` lalu menampilkannya di SnackBar.

## 5. Mini Game yang Aman Dijelaskan

**Tingkat 2.** Kerjakan setelah semua fitur Tingkat 1 (Bagian 3.5) stabil. Kalau game tidak sempat, tidak ada materi modul yang hilang: Hive sudah dibuktikan oleh cache katalog dan draft listing.

**"Food Saver Challenge" versi tombol** (tanpa gyroscope 3 arah seperti di rencana awal):

- Muncul kartu produk acak dengan sisa hari kedaluwarsa.
- Pemain memilih satu dari 3 tombol: **Jual Normal** (>30 hari), **Lelang** (7–30 hari), **Donasi** (<7 hari).
- Benar +10 poin, waktu 30 detik. Skor tertinggi disimpan di Hive box `game_scores`.

**Kode:** 1 screen + 1 model + list data lokal. Konsep yang dipakai hanya `Timer.periodic`, `Random`, `setState`, dan `dispose()` untuk menghentikan timer. Semuanya bisa dijelaskan dalam tiga kalimat. Karena Timer.periodic juga di luar modul, beri komentar elemen asing di kode game.

**Tahap 2 (opsional, kalau sudah lancar):** miringkan HP kiri/kanan untuk memilih, membaca sumbu-x akselerometer dari package `sensors_plus` yang sama dengan shake. Logikanya cukup satu `if (event.x > 5)`.

## 6. Struktur Kode

### 6.1 Migrasi dari kode sekarang

Kode Recovera sekarang memakai `features/`, `data/repositories`, `core/network`, Provider, Dio, sqflite, dan secure storage. Semua itu di luar pola modul, jadi diganti seperti ini:

| Lama | Baru | Alasan |
| --- | --- | --- |
| Provider | `StatefulWidget` + `setState` / `FutureBuilder` | Sesuai Modul III; tidak ada state management pihak ketiga |
| Dio + `AuthInterceptor` | `http` + `ApiService` (header Bearer diambil dari SharedPreferences) | Sesuai Modul V |
| `flutter_secure_storage` | SharedPreferences | Sesuai Modul VI. Tulis di laporan sebagai keterbatasan keamanan versi praktikum. |
| sqflite (5 tabel) | Hive (4 box) + SharedPreferences | Sesuai Modul VI |
| `features/*/repositories` | `services/` | Satu lapisan, lebih mudah ditelusuri |
| `local_auth`, magnetometer, `firebase_messaging`, `flutter_map`, web3 | Hapus dari `pubspec.yaml` | Fiturnya sudah dibuang |
| 4 service API terpisah (auth, listing, order, AI) | Satu ApiService (static method, dikelompokkan dengan komentar) | Modul V mengajarkan satu ApiService. Total service turun dari 10 ke 6 file. |

Saranku: **mulai project Flutter bersih**, lalu salin logika yang masih dipakai (model, parsing, aturan bisnis) ke struktur baru. Itu lebih cepat dan lebih rapi daripada membongkar struktur lama sedikit demi sedikit.

### 6.2 Struktur folder baru

```text
lib/
├── main.dart                       # ensureInitialized, Hive, notifikasi, cek sesi
├── theme/
│   └── app_theme.dart              # SATU-SATUNYA tempat warna, font, radius, spacing
├── models/
│   ├── user_model.dart
│   ├── listing_model.dart          # termasuk current_price, next_drop_at, jarak
│   ├── order_model.dart
│   ├── notification_model.dart
│   ├── invoice_result_model.dart   # hasil OCR
│   └── price_advice_model.dart     # hasil rekomendasi harga (+ source model/rule)
├── services/                       # 6 file (sebelumnya 10)
│   ├── api_service.dart            # SATU class static: auth, listing, order, AI, notifikasi
│   ├── session_service.dart        # SharedPreferences (token, peran, nama)
│   ├── local_db_service.dart       # Hive: cache, draft, skor game
│   ├── location_service.dart       # geolocator + hitung jarak
│   ├── notification_service.dart   # immediate + scheduled + checkNewNotifications
│   └── sensor_service.dart         # akselerometer (elemen asing, dikomentari)
├── screens/
│   ├── auth/        splash_screen, login_screen, register_screen
│   ├── shared/      main_shell (bottom nav per peran), profile_screen,
│   │                notification_screen, orders_screen (dipakai kedua peran),
│   │                game_screen                              [Tingkat 2]
│   ├── seller/      seller_dashboard_screen, seller_stock_screen,
│   │                upload_invoice_screen, listing_form_screen,
│   │                seller_listing_detail_screen
│   └── buyer/       catalog_screen, listing_detail_screen, order_detail_screen
└── widgets/
    ├── listing_card.dart
    ├── price_countdown.dart
    ├── filter_sheet.dart                                     [Tingkat 2]
    ├── status_badge.dart
    ├── empty_state.dart
    └── primary_button.dart
```

Subfolder `auth/`, `shared/`, `seller/`, dan `buyer/` di dalam `screens/` membantu saat ditanya "halaman penjual yang mana?". Setiap peran punya folder sendiri.

### 6.3 Aturan yang menjaga kode mudah dipahami

1. **Screen tidak pernah memanggil `http` atau Hive langsung.** Selalu lewat service.
2. **`baseUrl` hanya ditulis di satu tempat** (`api_service.dart`), supaya ganti alamat ngrok/server cukup satu baris.
3. **Satu file = satu layar atau satu widget.** Kalau sudah lewat ±250 baris, pecah ke `widgets/`.
4. **Hive mengikuti cara Modul VI.** Paling sederhana: simpan sebagai `Map` (`toMap`/`fromMap`) tanpa code generation.
5. **Elemen di luar modul** (`sensors_plus`, `image_picker`, `http.MultipartRequest`, `timezone`) wajib diberi komentar: apa fungsinya, kenapa dipakai, dan cara kerjanya.
6. **Selalu cek `if (!mounted) return;`** setelah `await`.

**Isi `ApiService`:** satu class, semua method `static`, dikelompokkan dengan komentar pemisah. Kalau file sudah lewat ±300 baris dan sulit dibaca, baru dipecah. Service lain tetap terpisah karena tugasnya memang bukan HTTP: sesi, Hive, lokasi, notifikasi, sensor.

```dart
// ApiService = SATU class berisi static method (pola Modul V).
// Dikelompokkan dengan komentar pemisah supaya mudah ditunjuk saat dijelaskan.
class ApiService {
  static const String baseUrl = 'https://...'; // satu-satunya tempat alamat server

  // ===== HELPER (dipakai semua method di bawah) =====
  // _headers()        -> menyisipkan Authorization: Bearer <token dari SharedPreferences>
  // _handleResponse() -> cek statusCode; kalau 401 lempar Exception('Sesi berakhir'),
  //                      layar yang menangkapnya kembali ke Login (pushAndRemoveUntil)

  // ===== AUTH ===========  login, register, logout, fetchProfile
  // ===== LISTING ========  fetchListings, fetchListingDetail, buyNow
  // ===== PENJUAL ========  fetchInventory, createDraft, publishListing, updateListing
  // ===== AI =============  uploadInvoice (multipart), fetchPriceAdvice
  // ===== ORDER ==========  fetchOrders, fetchOrderDetail, updateOrderStatus
  // ===== NOTIFIKASI =====  fetchNotifications, markNotificationRead
}
```

**Package:** `http`, `shared_preferences`, `hive`, `hive_flutter`, `geolocator`, `flutter_local_notifications`, `timezone`, `intl`. Elemen asing: `sensors_plus`, `image_picker`.

**Isi Hive dan SharedPreferences:**

| Penyimpanan | Isi |
| --- | --- |
| SharedPreferences | `access_token`, `role`, `user_name`, `is_logged_in` |
| Hive box `listings_cache` | Katalog terakhir (dipakai saat offline) |
| Hive box `orders_cache` | Pesanan terakhir |
| Hive box `draft_listings` | Draft upload penjual |
| Hive box `game_scores` | Skor mini game |

## 7. Alur Aplikasi

```text
Splash → cek is_logged_in
  ├─ belum → Login ⇄ Register (pilih peran)
  └─ sudah → MainShell sesuai role
        Penjual: Dasbor | Stok | Game | Profil
        Pembeli: Katalog | Pesanan | Game | Profil
        (lonceng notifikasi di AppBar, Logout di Profil)
```

### Skenario demo (2 HP atau ganti akun)

1. **Penjual:** Stok → Upload → foto faktur → form terisi otomatis (OCR) → rekomendasi harga muncul → Terbitkan → notifikasi "Listing terbit".
2. **Pembeli:** goyang HP → katalog refresh, listing baru muncul beserta jarak gudang.
3. Buka detail → harga berjalan + countdown → tekan "Ingatkan saya" (notifikasi terjadwal).
4. Beli Sekarang → konfirmasi → notifikasi "Pembelian berhasil".
5. **Penjual:** Dasbor → pesanan masuk → tandai diambil → **Pembeli** melihat status berubah.
6. Matikan internet → katalog tetap tampil dari cache Hive.
7. Buka Game → main satu ronde → skor tersimpan.

Aktifkan `TIME_SCALE` di backend (sudah ada di PRD) supaya penurunan harga terlihat saat demo.

## 8. Persiapan Diminta Ganti Warna/Layout On the Spot

- **Semua warna hanya di `theme/app_theme.dart`.** Di screen dilarang menulis `Color(0xFF...)` langsung.
- **Warna status pesanan** (`paid`, `picked_up`, `completed`) juga diatur dari theme lewat widget `StatusBadge`.
- **Kartu listing jadi satu widget** (`ListingCard`). Ubah sekali, dan katalog serta stok penjual ikut berubah.

Latih skenario ini:

1. Ganti warna utama.
2. Katalog grid 2 kolom jadi list (atau sebaliknya).
3. Pindahkan tombol "Beli Sekarang" dari bawah layar ke AppBar.
4. Tambah satu field di form listing (model → controller + dispose → service → tampilan).
5. Ubah urutan atau ikon tab di bottom nav.

## 9. Yang Perlu Disinkronkan di PRD & Schema

PRD dan schema tetap jadi pegangan, tapi bagian-bagian berikut harus diperbarui supaya tidak bertentangan dengan versi praktikum.

**PRD:**

- US-01: secure storage → SharedPreferences; tanpa silent refresh (401 → kembali ke Login).
- US-02 (biometrik), US-08 (ESG/blockchain), US-09 & US-10 (konversi), US-16 (Saran & Kesan): tandai **tidak termasuk versi praktikum**.
- US-05: peta OSM dihapus, jarak ditampilkan sebagai teks.
- US-06: Buy Now memakai dialog konfirmasi, bukan biometrik.
- US-07: FCM → local notification + inbox.
- US-11: sensor = akselerometer saja (shake + game). Magnetometer dihapus.
- US-12: SQLite → Hive; auto-sync draft → terbitkan manual.
- US-14: mini game versi tombol.
- US-15: bottom nav 5 tab → 4 tab per peran; Logout pindah ke Profil.
- Decision Log D1: LightGBM **aktif** dengan fallback rumus (bukan menunggu v1.1).

**Schema:**

- Tabel online yang tidak dipakai app versi praktikum: `donations`, `offtakers`, `device_tokens`, `course_feedbacks`. **Jangan di-drop** dari database; cukup ditandai supaya backend tidak rusak.
- Database lokal: 5 tabel SQLite diganti 4 box Hive + SharedPreferences (tabel di Bagian 6.3).

**Laporan:** samakan penyebutan **Gemini** (di FR-04 masih tertulis Qwen Vision API).

## 10. Langkah Berikutnya

1. Perbarui PRD dan schema sesuai Bagian 9.
2. Buat project Flutter bersih dengan struktur Bagian 6, lalu bersihkan `pubspec.yaml`.
3. Susun design system (token warna, tipografi, radius); hasilnya langsung jadi isi `app_theme.dart`. Ini tahap perbaikan tampilan.
4. **Urutan build:** `api_service` + `session_service` → auth → katalog + detail → beli + pesanan → lokasi → notifikasi immediate + scheduled → shake → upload penjual (OCR + rekomendasi + publish) → stok + pesanan masuk. Itu Tingkat 1; demokan dulu. Lalu Tingkat 2: pop-up dari server → game → filter lanjutan → polish tampilan.
5. Siapkan backend untuk demo (ngrok atau server, `TIME_SCALE`) dan tes di HP fisik sejak awal, terutama notifikasi dan sensor.
