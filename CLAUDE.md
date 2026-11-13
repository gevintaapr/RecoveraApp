# Recovera — TA Praktikum Pemrograman Aplikasi Mobile (Flutter)

Aplikasi B2B likuidasi pangan near-expiry. Dua peran: **Penjual** dan **Pembeli**.
Backend FastAPI sudah jadi dan terpisah dari repo ini; Flutter hanya klien.

Dokumen rujukan (baca hanya saat dibutuhkan, jangan dibaca semua sekaligus):
- `docs/Panduan Proyek Akhir PAM — Recovera Versi Praktikum.md` (selanjutnya "panduan") — panduan proyek lengkap (fitur, struktur, kode contoh notifikasi)
- `docs/backend-client-contract.md` — kontrak endpoint dan bentuk response
- `docs/recovera-prd-full-platform.md`, `docs/recovera-database-schema.md` — PRD dan skema
- `../recovera` — proyek lama, **hanya referensi baca** (lihat bagian "Folder lama")
- Draf rancangan (notifikasi, GetX, favorit, kesesuaian modul): https://claude.ai/artifact/NpZxqi3AfXwPa4xVsM2ybX

## Aturan utama: hanya materi Modul I–VIII

Proyek ini harus membuktikan penerapan modul. Pola di luar modul hanya boleh dipakai bila benar-benar perlu, dan wajib diberi komentar (lihat "Elemen di luar modul"). Modul (PDF) ada di folder induk `../`.

**Dilarang:** Provider, Bloc, Riverpod, MobX, Redux, Dio, sqflite, flutter_secure_storage, local_auth, firebase_messaging, flutter_map, web3, go_router, freezed, json_serializable.

**Dipakai:**
- State: `StatefulWidget` + `setState`, `FutureBuilder`, `ValueListenableBuilder` (Hive). `StatelessWidget` bila tidak ada state.
- GetX (Modul VIII) **hanya sebagian**, untuk state yang dipakai lintas halaman: Favorit dan badge notifikasi. Bentuknya `GetxController` + `.obs` + `Obx`, `Get.put` / `Get.find` / `Get.lazyPut`, `GetMaterialApp`, dan satu named route (`GetPage` + `Bindings` + `Get.toNamed`) untuk halaman Favorit. Layar lain tetap `setState` + `Navigator`, supaya bukti Modul III dan IV tetap terlihat.
- Navigasi: `Navigator.push / pop / pushReplacement / pushAndRemoveUntil`; data dikirim lewat parameter konstruktor; `BottomNavigationBar` dengan array `_pages[_selectedIndex]`.
- HTTP: package `http` (`http.get`, `http.post`, `http.MultipartRequest` untuk upload) dengan `Future`, `async`, `await`.
- Penyimpanan: `shared_preferences` untuk sesi; `hive` + `hive_flutter` untuk cache, draft, dan favorit. Ikuti Modul VI: model Hive memakai `@HiveType` / `@HiveField` + `TypeAdapter` hasil `hive_generator` + `build_runner` (`dart run build_runner build`), didaftarkan dengan `Hive.registerAdapter` di `LocalDbService.init()` yang dipanggil `main.dart`. Setelah mengubah model ber-`@HiveType`, jalankan ulang `dart run build_runner build --delete-conflicting-outputs`.
- Lokasi: `geolocator`. Notifikasi: `flutter_local_notifications` (immediate + scheduled), `timezone`.
- Di luar modul (wajib dikomentari): `sensors_plus`, `image_picker`, `http.MultipartRequest`, `timezone`, `Timer`.

## Struktur folder (jangan menambah lapisan selain yang tertulis)

```
lib/
├── main.dart                 # ensureInitialized, Hive, notifikasi, cek sesi
├── theme/app_theme.dart      # SATU-SATUNYA tempat warna, font, radius, spacing
├── models/                   # user, listing, order, notification, invoice_result, price_advice, favorit (+ .g.dart)
├── controllers/              # GetX: favorit_controller, notifikasi_controller
├── bindings/                 # GetX: favorit_binding
├── routes/                   # GetX: app_routes (nama rute), app_pages (GetPage + binding)
├── services/                 # tepat 6 file
│   ├── api_service.dart      # SATU class, semua method static
│   ├── session_service.dart  # SharedPreferences
│   ├── local_db_service.dart # Hive
│   ├── location_service.dart # geolocator + jarak
│   ├── notification_service.dart  # immediate + scheduled + checkNewNotifications
│   └── sensor_service.dart   # akselerometer
├── screens/
│   ├── auth/    splash, login, register
│   ├── shared/  main_shell, profile, notification, orders (dipakai kedua peran), game
│   ├── seller/  dashboard, stock, upload_invoice, listing_form, listing_detail
│   └── buyer/   catalog, listing_detail, order_detail, favorit
└── widgets/     listing_card, price_countdown, filter_sheet, status_badge, empty_state, primary_button, tombol_favorit
```

Jangan membuat folder `features/`, `repositories/`, `providers/`, `core/`, atau service baru tanpa izin. Fungsi baru masuk ke file yang sudah ada. Controller GetX tidak memanggil `http` atau Hive langsung; ia memanggil service.

## Aturan kode

1. **Screen tidak memanggil `http` atau Hive langsung.** Selalu lewat service.
2. **`ApiService`** = satu class, semua method `static`, dikelompokkan dengan komentar pemisah (HELPER, AUTH, LISTING, PENJUAL, AI, ORDER, NOTIFIKASI). `baseUrl` hanya ditulis di satu tempat. Header `Authorization: Bearer <token>` diambil dari SharedPreferences lewat helper.
3. **Alur data 3 tahap:** Fetch → Parse (`Model.fromJson`) → Render (`CircularProgressIndicator` saat loading, pesan error saat gagal).
4. **Response backend** berbentuk `{success, data}` atau `{success, error}`. `ApiService` membaca `error.message` lalu melempar `Exception` dengan pesan itu.
5. **401:** `ApiService` melempar `Exception('Sesi berakhir')`; layar yang menangkapnya menghapus sesi dan `pushAndRemoveUntil` ke Login. Tidak ada refresh token otomatis.
6. **Wajib `if (!mounted) return;`** setelah setiap `await` sebelum memakai `setState`, `Navigator`, atau `ScaffoldMessenger`.
7. **Wajib `dispose()`** untuk setiap `TextEditingController`, `Timer`, dan subscription sensor.
8. **Penamaan deskriptif dalam bahasa Indonesia** yang maknanya langsung dimengerti: method, variabel, parameter, dan widget privat (`sedangMemuat`, `sudahLogin`, `daftarListing`, `emailController`, `ambilProfil()`, `simpanSesi()`). Nama file dan class mengikuti struktur folder di atas (`ApiService`, `SessionService`, `UserModel`) agar cocok dengan panduan. Yang tetap bahasa Inggris: API Flutter/Dart (`build`, `initState`, `dispose`), `fromJson` / `toMap` / `fromMap`, kunci JSON dari backend, dan kata yang sudah lazim (`token`, `listing`, `email`, `controller`). Tipe data eksplisit (`String`, `int`, `double`, `bool`, `List<Model>`); hindari `var` / `dynamic` tanpa alasan kuat.
9. **Satu file = satu layar atau satu widget.** Lewat ±250 baris, pecah ke `widgets/`.
10. **Semua warna, font, radius, spacing hanya dari `theme/app_theme.dart`.** Dilarang menulis `Color(0x...)` atau angka ukuran font langsung di screen atau widget.
11. Widget kecil yang berulang (kartu listing, badge status, empty state, tombol utama) dibuat sekali di `widgets/` dan dipakai ulang.
12. **Wajib "buffer" (loading) untuk setiap aksi yang butuh waktu** (login, daftar, beli, logout, upload faktur/gambar, terbitkan, ubah status, jadwalkan pengingat, dll.), dan tombolnya tidak bisa ditekan dua kali selama proses:
    - tombol utama → `PrimaryButton(sedangMemuat: true)`;
    - aksi dari ikon/dialog → `tampilkanDialogMemuat(context, pesan: ...)` (`widgets/dialog_memuat.dart`), lalu `Navigator.pop(context)` setelah selesai atau gagal;
    - memuat data layar → `CircularProgressIndicator` dari `FutureBuilder`.

## Elemen di luar modul (wajib dikomentari)

Format komentar, tepat di atas kodenya:

```dart
// CATATAN: Menggunakan <elemen> (elemen di luar modul)
// Fungsi: <apa yang dikerjakan>
// Alasan: <kenapa terpaksa dipakai>
// Cara kerja: <penjelasan sederhana>
```

## Penyimpanan lokal

| Tempat | Isi |
|---|---|
| SharedPreferences | `access_token`, `role`, `user_name`, `is_logged_in`, `last_notif_id` |
| Hive `listings_cache` | katalog terakhir (tampil saat offline, dengan label "Data offline") |
| Hive `orders_cache` | pesanan terakhir |
| Hive `draft_listings` | draft upload penjual (diterbitkan manual lewat tombol "Terbitkan") |
| Hive `game_scores` | skor mini game |
| Hive `favorit_listing` | listing lelang yang disimpan pembeli (kunci = id listing), dibaca lewat `FavoritController` |

Saat logout: hapus semua key sesi **termasuk `last_notif_id`**, lalu `pushAndRemoveUntil` ke Login.

## Notifikasi

- Channel ID: `recovera_channel_v2`. `Importance.max`, `Priority.high`. ID channel tidak boleh dipakai ulang bila pengaturannya diubah (Android tidak mengubah channel yang sudah dibuat).
- ID notifikasi harus **unik** per notifikasi (bukan selalu 0).
- Tiga sumber pop-up:
  1. Aksi sendiri (beli berhasil, listing terbit) → `showInstantNotification`.
  2. Tombol "Ingatkan saya" 30 menit sebelum lelang berakhir → `scheduleNotification` (tetap muncul walau aplikasi ditutup).
  3. Notifikasi server → `checkNewNotifications()` dipanggil **sekali** di `initState` `MainShell`, dan setiap `notification_screen` dibuka atau ditarik ke bawah (`RefreshIndicator`). **Tanpa `Timer`, tanpa `WidgetsBindingObserver`.**
- Batasan yang harus jujur disebut saat presentasi: tanpa FCM, pop-up dari server hanya muncul saat aplikasi dibuka atau di-refresh.

## Endpoint

Dipakai: `/auth/register`, `/auth/login`, `/auth/logout`, `GET /profile`, `GET /listings`, `GET /listings/{id}`, `POST /listings/{id}/buy`, `GET /listings/my`, `/listings/seller/inventory` (+ `drafts`, `recommendation`, `publish`), `PATCH /listings/{id}`, `POST /ai/invoice` (multipart), `GET /orders`, `GET /orders/{id}`, `PATCH /orders/{id}/status`, `GET /notifications`, `PATCH /notifications/{id}/read`.

Pengecualian `/products`: **`POST /products/upload-image`** (multipart, field `file`) boleh dipakai untuk upload gambar produk penjual; hasilnya `image_url` untuk membuat draft.

**Tidak dipakai (jangan dipanggil):** `/auth/refresh`, `PATCH /profile`, `/products` (selain upload-image), `POST /listings` (diganti alur draft), `/donations/*`, `/blockchain*`, `/rates`, `/devices`, `/feedback`. Detail ada di `docs/backend-client-contract.md`.

Harga lelang Belanda **dihitung server** (`current_price`, `next_drop_at`). Flutter hanya menampilkan dan membuat countdown; jangan menghitung ulang harga di klien.

## Fitur yang sengaja dibuang (jangan ditambahkan kembali)

Biometrik, Saran & Kesan, FCM, sertifikat ESG + SHA-256 / blockchain, kompas magnetometer, peta OSM / pin picker, konversi mata uang dan waktu, refresh token otomatis. Jarak ke gudang cukup teks, misalnya "2,4 km".

## Prioritas pengerjaan

**Tingkat 1 (wajib selesai dan bisa didemokan dulu):** splash/login/register/sesi/shell per peran/logout; katalog, detail, **favorit (Hive + GetX)**, Beli Sekarang, pesanan, cache katalog + draft di Hive; penjual (upload faktur OCR → rekomendasi harga → terbitkan, stok, pesanan masuk); lokasi dan jarak; notifikasi immediate + scheduled + inbox.

**Tingkat 2 (setelah Tingkat 1 stabil, urut):** pop-up notifikasi dari server; shake-to-refresh (sensor tidak ada di Modul I–VIII); mini game "Food Saver Challenge" (versi tombol, skor di Hive); filter lanjutan (bottom sheet) + sort; ketuk pop-up membuka halaman; polish tampilan.

**Urutan build:** `api_service` + `session_service` → auth → katalog + detail → favorit (Hive + GetX) → beli + pesanan → lokasi → notifikasi immediate + scheduled → upload penjual → stok + pesanan masuk → (Tingkat 2).

Bila waktu mepet, selesaikan peran Pembeli sampai tuntas dulu, baru lengkapi Penjual.

## Cara kerja dengan saya

- Kerjakan **satu langkah per permintaan** dari urutan build. Jangan membuat banyak layar sekaligus.
- Setelah menulis kode, jelaskan singkat alurnya (layar ini menampilkan apa, datanya dari method `ApiService` mana, `setState` terjadi kapan) supaya pemilik proyek bisa menjelaskannya ke penguji. Target: tiap layar bisa dijelaskan dalam satu menit.
- Jangan menambah package, fitur, folder, atau pola baru tanpa bertanya dulu.
- Bila sebuah aturan di sini bertabrakan dengan permintaan, tanyakan; jangan diam-diam melanggar.
- Setelah perubahan, jalankan `flutter analyze` dan pastikan tidak ada error atau import yang tidak terpakai.
- Kode contoh notifikasi lengkap ada di panduan bagian 3.4.

## Folder lama (`../recovera`)

Hanya untuk dibaca. Boleh dipakai sebagai contoh model, daftar endpoint, isi pemanggilan API, layout layar, dan konfigurasi `AndroidManifest.xml`. **Jangan menyalin** pola Provider, Dio, interceptor, sqflite, struktur `features/`, atau repository. Port satu file per permintaan dan tulis ulang sesuai aturan di atas.

## Perintah

```
flutter pub get
flutter analyze
flutter run          # uji di HP fisik, terutama notifikasi dan sensor
```

Untuk demo lelang, backend dijalankan dengan `TIME_SCALE` agar harga turun cepat. `baseUrl` diisi alamat ngrok atau server saat demo.
