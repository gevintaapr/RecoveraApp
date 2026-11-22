# Draf Rancangan Recovera 2.0 — Notifikasi, GetX, Favorit & Kesesuaian Modul

Nov 13, 2026 · @gepi

## Ringkasan keputusan

Recovera 2.0 tidak perlu Firebase: Modul VII hanya mengajarkan Local Notification (immediate + scheduled), sedangkan Push Notification/FCM hanya disebut di teori. GetX (Modul VIII) diterapkan sebagian, hanya untuk state yang dipakai lintas halaman, supaya bukti Modul III (setState) dan Modul IV (Navigator) tetap terlihat.

| Topik | Keputusan draf | Alasan singkat |
| --- | --- | --- |
| Notifikasi | Tanpa Firebase. Immediate + scheduled dari `flutter_local_notifications`, ditambah inbox dari `GET /notifications` yang dimunculkan sebagai pop-up lokal | Sesuai Modul VII; FCM di repo lama di luar modul |
| GetX | Sebagian: Favorit dan badge notifikasi memakai `GetxController` + `Obx` + `Get.put/Get.find`; satu rute (Favorit) memakai named route + Binding | Tiga pilar Modul VIII terbukti tanpa menghapus bukti Modul III dan IV |
| Favorit lelang | Fitur baru, disimpan lokal di Hive box `favorit_listing`, ada halaman daftar favorit | Menambah bukti Modul VI dan menjadi kasus nyata state lintas halaman untuk GetX |
| Hive | Ikuti Modul VI: `TypeAdapter` + `hive_generator` + `build_runner` | Modul VI memakainya; aturan CLAUDE.md lama (tanpa code generation) perlu diubah |
| Navigasi | Tetap `Navigator.push/pop/pushReplacement/pushAndRemoveUntil` + `BottomNavigationBar` | Bukti utama Modul IV |

Dokumen ini masih draf. Poin yang perlu disetujui dulu ada di bagian terakhir.

## Notifikasi: apa yang diwajibkan modul

Yang diwajibkan adalah Local Notification, bukan Firebase. Modul IV yang disebut di pertanyaan hanya membahas navigasi; notifikasi ada di Modul VII. Modul VII membandingkan dua jenis notifikasi, lalu menyatakan praktikumnya fokus pada Local Notification jenis immediate dan scheduled. Tugasnya: aplikasi to-do yang menerapkan notification dan LBS.

| Aspek | Repo GitHub terbaru (`ardiw1123/recovera`) | Recovera 2.0 (draf ini) |
| --- | --- | --- |
| Package | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` | `flutter_local_notifications`, `timezone` |
| Sumber pop-up | Server mengirim lewat FCM, HP menerima walau aplikasi ditutup | Aksi di HP, jadwal di HP, dan inbox server yang dicek saat aplikasi dibuka |
| Backend | `push_service.py` + `POST /devices` untuk token FCM | Cukup `GET /notifications` dan `PATCH /notifications/{id}/read` yang sudah ada |
| Status modul | Di luar modul (wajib dikomentari, sulit dijelaskan) | Sesuai Modul VII |
| Kelemahan | Setup Firebase, `google-services.json`, rawan gagal saat demo | Pop-up dari server hanya muncul saat aplikasi dibuka atau di-refresh |

**Tiga sumber pop-up di Recovera 2.0** (semuanya lewat `NotificationService`, channel `recovera_channel_v2`, ID unik per notifikasi):

1. **Aksi sendiri (immediate):** setelah Beli Sekarang berhasil atau listing terbit, layar memanggil `showInstantNotification(judul, isi)`.
2. **Pengingat lelang (scheduled):** tombol "Ingatkan saya" di detail listing memanggil `scheduleNotification(id, judul, isi, waktu)` untuk 30 menit sebelum `lelangBerakhir`. Tetap muncul walau aplikasi ditutup karena dijadwalkan oleh Android.
3. **Inbox server (jembatan ke pop-up lokal):** `checkNewNotifications()` memanggil `ApiService.ambilNotifikasi()`, membandingkan dengan `last_notif_id` di SharedPreferences, lalu memunculkan yang baru dengan `showInstantNotification`. Dipanggil sekali di `initState` MainShell dan setiap layar Notifikasi dibuka atau ditarik ke bawah. Tanpa `Timer`.

Yang perlu disampaikan jujur saat presentasi: tanpa FCM, notifikasi dari server (misalnya "pesanan Anda diproses penjual") baru muncul saat aplikasi dibuka. Kalau asisten mewajibkan push sungguhan, FCM dari repo lama bisa dipasang kembali sebagai elemen di luar modul yang dikomentari; itu keputusan yang perlu ditanyakan dulu.

## GetX: sebagian, bukan semua

Saran: terapkan GetX sebagian. Kalau semua layar diganti GetX, `setState` (Modul III) dan `Navigator` + passing data lewat konstruktor (Modul IV) hilang dari kode, padahal keduanya juga dinilai. Modul VIII sendiri menyebut `setState` tetap cocok untuk kasus sederhana dan GetX dipakai saat state harus sinkron di banyak halaman.

Tugas Modul VIII meminta tiga pilar sekaligus: state management, dependency injection, dan routing. Ketiganya bisa dibuktikan di satu fitur yang memang butuh: Favorit.

| Pilar GetX | Dipakai di | Bentuk kodenya |
| --- | --- | --- |
| State management | `FavoritController`: daftar favorit `RxList<ListingModel>`; `NotifikasiController`: jumlah belum dibaca `RxInt` | `.obs` di controller, `Obx(() => ...)` di ikon hati, badge, dan halaman Favorit |
| Dependency injection | Controller didaftarkan sekali, dipakai di banyak layar | `Get.put(FavoritController())` di `main.dart`, `Get.find<FavoritController>()` di kartu listing, detail, dan halaman Favorit |
| Routing | Hanya rute halaman Favorit | `GetMaterialApp` + `GetPage(name: AppRoutes.favorit, page: ..., binding: FavoritBinding())`, dibuka dengan `Get.toNamed(AppRoutes.favorit)` |
| Lifecycle | `onInit()` memuat favorit dari Hive saat controller dibuat | Modul VIII Contoh 8.6 |

**Yang tetap tanpa GetX:** login/register/katalog/detail/pesanan memakai `StatefulWidget` + `setState` + `FutureBuilder`; semua perpindahan halaman lain memakai `Navigator`; BottomNavigationBar tetap `_pages[_selectedIndex]`.

**Konsekuensi:**

- `MaterialApp` diganti `GetMaterialApp`. `Navigator.push` tetap berjalan normal di dalamnya, jadi kode yang sudah ada tidak perlu diubah.
- Struktur folder bertambah `controllers/`, `bindings/`, dan `routes/` (pola Modul VIII). Ini melanggar aturan CLAUDE.md saat ini ("jangan menambah lapisan"), jadi CLAUDE.md perlu diperbarui.
- Package `get` masuk daftar "Dilarang" di CLAUDE.md dan harus dipindah ke "Dipakai".

Alternatif bila asisten ingin GetX penuh: semua halaman memakai controller + `Get.to/Get.off/Get.offAll`. Itu sekitar dua kali lipat perubahan dan menghapus bukti Modul III/IV, jadi sebaiknya ditanyakan dulu.

## Fitur baru: Favorit (simpan produk lelang)

Pembeli bisa menyimpan listing lelang ke HP dengan ikon hati, lalu melihat semuanya di halaman Favorit. Data hanya ada di HP (Hive), tidak dikirim ke server, dan tetap ada walau aplikasi ditutup atau offline.

**Yang disimpan per favorit** (satu entri di box `favorit_listing`, kunci = id listing): id, nama produk, URL gambar, harga saat disimpan, harga normal, waktu lelang berakhir, nama penjual, dan waktu disimpan. Harga yang tampil di halaman Favorit adalah harga saat disimpan; harga terbaru dimuat dari server saat favorit dibuka ke detail.

**Alur pengguna:**

1. Di kartu katalog atau di detail, pembeli mengetuk ikon hati. Ikon langsung terisi (`Obx`) dan SnackBar "Disimpan ke Favorit" muncul.
2. Badge angka di ikon Favorit pada AppBar katalog ikut bertambah, tanpa `setState` dan tanpa mengoper data antar layar.
3. Ikon Favorit dibuka dengan `Get.toNamed(AppRoutes.favorit)`. Halaman ini menampilkan daftar dari Hive, berlabel "Harga saat disimpan".
4. Mengetuk item membuka detail (`Navigator.push` + `idListing`), yang memuat harga terbaru dari server.
5. Hati diketuk lagi, atau item digeser (swipe) di halaman Favorit, untuk menghapus. Listing yang lelangnya sudah berakhir diberi label "Lelang berakhir".
6. Opsional, menyatu dengan notifikasi: tombol "Ingatkan saya" di item favorit menjadwalkan scheduled notification 30 menit sebelum lelang berakhir.

**Fungsi yang dibuat:**

| File | Fungsi | Tugas |
| --- | --- | --- |
| `models/favorit_model.dart` | `FavoritModel` + `@HiveType`, `FavoritModel.dariListing(listing)` | Bentuk data yang disimpan di Hive |
| `services/local_db_service.dart` | `ambilSemuaFavorit()`, `simpanFavorit(favorit)`, `hapusFavorit(idListing)` | Satu-satunya kode yang menyentuh box Hive |
| `controllers/favorit_controller.dart` | `daftarFavorit` (RxList), `onInit()`, `apakahFavorit(id)`, `toggleFavorit(listing)`, `hapus(id)`, `jumlahFavorit` | Logika favorit; memanggil `LocalDbService` |
| `bindings/favorit_binding.dart` | `dependencies()` dengan `Get.lazyPut` | Menyiapkan controller sebelum halaman Favorit dibuka |
| `screens/buyer/favorit_screen.dart` | `Obx` + `ListView.builder` + `Dismissible` | Menampilkan dan menghapus favorit |
| `widgets/tombol_favorit.dart` | `TombolFavorit(listing)` dengan `Obx` | Ikon hati yang dipakai ulang di kartu dan detail |

Ikon Favorit sebaiknya di AppBar katalog, bukan tab baru, karena empat tab pembeli (Katalog, Pesanan, Game, Profil) sudah ditetapkan di panduan.

## Kesesuaian dengan Modul I–VIII

Rancangan sudah sesuai untuk Modul I–V dan VII, dengan satu catatan besar di Modul VI: modul memakai `TypeAdapter` + `hive_generator` + `build_runner`, sedangkan CLAUDE.md melarang code generation dan menyimpan Hive sebagai `Map`. Saran: ikuti modul. Modul VIII (GetX) belum ada di rancangan dan baru masuk lewat draf ini.

| Modul | Materi inti di modul | Bukti di Recovera 2.0 | Status |
| --- | --- | --- | --- |
| I. Pengenalan & Setup | Struktur proyek, `main()`, `runApp`, `MaterialApp` | `main.dart`, `RecoveraApp` | Sudah |
| II. Widget | Row/Column, `ListView.builder`, `GridView`, `Card`, `Image.network` | `ListingCard`, katalog `ListView.builder`, detail; `GridView` belum dipakai | Sebagian (GridView bisa di halaman Favorit atau dasbor penjual) |
| III. State & Data | `StatefulWidget`, `setState`, `TextEditingController`, form + validasi | Login, register, pencarian katalog | Sudah |
| IV. Navigation | `push`, `pop`, `pushReplacement`, `pushAndRemoveUntil`, passing data lewat konstruktor, `BottomNavigationBar` | Splash→Login (`pushReplacement`), katalog→detail (`push` + `idListing`), logout (`pushAndRemoveUntil`), `MainShell` | Sudah; `Navigator.pop` eksplisit perlu ditambah (mis. setelah beli berhasil) |
| V. HTTP Request | `http.get/post`, `jsonDecode`, `fromJson`, `Future/async/await`, `FutureBuilder` | `ApiService`, `UserModel`, `ListingModel`, katalog & detail | Sudah |
| VI. Local Storage | SharedPreferences; Hive dengan `@HiveType`, `TypeAdapter`, `build_runner`, `box.listenable()` + `ValueListenableBuilder` | `SessionService` sudah; Hive (cache katalog, draft, favorit) belum dibuat | Sebagian; ubah aturan Hive agar memakai TypeAdapter |
| VII. Notification & LBS | `flutter_local_notifications` immediate + scheduled, `timezone`, izin Android, `geolocator` + hitung jarak | Direncanakan: `NotificationService`, "Ingatkan saya", inbox; `LocationService` untuk jarak gudang | Belum dibuat |
| VIII. GetX | `.obs`, `Obx`, `GetxController` + `onInit`, `Get.put/find/lazyPut`, `GetMaterialApp`, `GetPage`, `Bindings`, `Get.toNamed` + `Get.arguments` | Direncanakan: Favorit + badge notifikasi | Belum; perlu izin ubah CLAUDE.md |

**Elemen di luar modul yang tetap dipakai (wajib dikomentari):** `http.MultipartRequest` untuk upload faktur OCR, `image_picker`, `sensors_plus` (shake), dan `Timer` (countdown, Tingkat 2). Tugas Modul VI dan VIII sama-sama berupa keranjang belanja; Recovera memakai pembelian langsung ("Beli Sekarang"), jadi Favorit menjadi padanan "keranjang" untuk membuktikan Hive dan GetX.

## Daftar fungsi yang dipakai

Saat ini 15 file sudah ada dan lolos `flutter analyze`; sisanya masih rencana. Nama fungsi berbahasa Indonesia, kecuali API Flutter (`build`, `initState`, `fromJson`) dan nama di Modul VII (`showInstantNotification`, `scheduleNotification`) yang dipertahankan agar mudah dicocokkan dengan modul.

| File | Fungsi | Gunanya | Status |
| --- | --- | --- | --- |
| `services/api_service.dart` | `_buatHeader`, `_kirim`, `_olahResponse` | Header Bearer, batas waktu 20 detik, baca `{success, data/error}`, 401 → "Sesi berakhir" | Sudah |
| `services/api_service.dart` | `masuk`, `daftar`, `keluar`, `ambilProfil` | Auth dan profil | Sudah |
| `services/api_service.dart` | `ambilDaftarListing`, `ambilDetailListing` | Katalog dan detail | Sudah |
| `services/api_service.dart` | `beliSekarang`, `ambilPesanan`, `ambilDetailPesanan`, `ubahStatusPesanan` | Beli dan pesanan | Rencana |
| `services/api_service.dart` | `ambilInventaris`, `buatDraft`, `ubahDraft`, `ambilRekomendasiHarga`, `terbitkanListing`, `ubahListing`, `unggahFaktur`, `unggahGambarProduk` | Alur penjual dan AI | Rencana |
| `services/api_service.dart` | `ambilNotifikasi`, `tandaiNotifikasiDibaca` | Inbox notifikasi | Rencana |
| `services/session_service.dart` | `simpanSesi`, `ambilToken`, `ambilPeran`, `ambilNamaPengguna`, `sudahLogin`, `ambilIdNotifTerakhir`, `simpanIdNotifTerakhir`, `hapusSesi` | Sesi di SharedPreferences | Sudah |
| `services/local_db_service.dart` | `init`, `simpanCacheKatalog`, `ambilCacheKatalog`, `simpanDraft`, `hapusDraft`, `ambilSemuaFavorit`, `simpanFavorit`, `hapusFavorit`, `simpanSkorGame` | Semua akses Hive | Rencana |
| `services/notification_service.dart` | `init`, `showInstantNotification`, `scheduleNotification`, `batalkanPengingat`, `checkNewNotifications` | Pop-up lokal + jembatan inbox server | Rencana |
| `services/location_service.dart` | `ambilLokasiSaatIni`, `hitungJarakKm` | `geolocator`, izin lokasi, jarak ke gudang | Rencana |
| `services/sensor_service.dart` | `mulaiDeteksiGoyang`, `berhenti` | Shake-to-refresh | Rencana |
| `controllers/favorit_controller.dart` | `onInit`, `apakahFavorit`, `toggleFavorit`, `hapus`, `jumlahFavorit` | State favorit (GetX) | Rencana |
| `controllers/notifikasi_controller.dart` | `jumlahBelumDibaca`, `muatUlang`, `tandaiDibaca` | Badge lonceng (GetX) | Rencana |
| `models/` | `UserModel.fromJson`, `ListingModel.fromJson`, `formatRupiah`, `formatJarak`, `formatJam`, `formatTanggal` | Parsing dan format tampilan | Sudah |
| `models/` | `OrderModel`, `NotifikasiModel`, `HasilFakturModel`, `SaranHargaModel`, `FavoritModel` | Parsing data lain | Rencana |
| `widgets/` | `PrimaryButton`, `EmptyState`, `ListingCard` | Dipakai ulang | Sudah |
| `widgets/` | `TombolFavorit`, `StatusBadge`, `PriceCountdown`, `FilterSheet` | Dipakai ulang | Rencana |

## Perbedaan dengan konsep sebelumnya

Ada tiga versi yang dibandingkan: proyek lama (`ardiw1123/recovera`, commit terakhir 31 Okt 2026), panduan awal (Panduan Proyek Akhir PAM + CLAUDE.md), dan draf ini. Draf ini mengubah tiga hal dari panduan awal: GetX masuk sebagian, Hive ikut cara Modul VI, dan ada fitur Favorit.

| Aspek | Proyek lama | Panduan awal | Draf ini |
| --- | --- | --- | --- |
| State | Provider | `setState` + `FutureBuilder` saja; GetX dilarang | `setState` + `FutureBuilder`, ditambah GetX untuk Favorit dan badge notifikasi |
| Navigasi | `Navigator` di dalam struktur `features/` | `Navigator` + `BottomNavigationBar` | Sama, ditambah satu named route GetX (Favorit) |
| HTTP | Dio + `AuthInterceptor`, 4 service API | `http` + satu `ApiService` static | Sama dengan panduan awal |
| Sesi | `flutter_secure_storage` | SharedPreferences | Sama dengan panduan awal |
| Database lokal | sqflite (5 tabel) | Hive disimpan sebagai `Map`, tanpa code generation | Hive dengan `TypeAdapter` + `build_runner` (sesuai Modul VI) |
| Notifikasi | FCM (`firebase_messaging`) + `POST /devices` | Local: immediate + scheduled + inbox, tanpa `Timer` | Sama dengan panduan awal, ditambah badge belum dibaca via GetX |
| Fitur | Biometrik, ESG/blockchain, kompas, peta OSM, konversi mata uang | Fitur itu dibuang | Sama, ditambah Favorit |
| Struktur | `core/`, `data/repositories`, `features/` | `services/` (6 file), `screens/`, `widgets/` | Sama, ditambah `controllers/`, `bindings/`, `routes/` |
| Penamaan | Inggris | Belum diatur | Bahasa Indonesia untuk method dan variabel |

**Yang perlu diubah di CLAUDE.md bila draf disetujui:** pindahkan `get`, `hive_generator`, dan `build_runner` dari "Dilarang" ke "Dipakai"; tambahkan folder `controllers/`, `bindings/`, `routes/`; tambahkan box `favorit_listing`; tambahkan Favorit ke prioritas Tingkat 1.

## Alur aplikasi per peran

Semua pengguna lewat Splash dan Login yang sama; MainShell lalu menampilkan empat tab sesuai peran. Hanya Favorit dan badge Notifikasi yang memakai GetX.

&#91;embedded content: alur aplikasi · 2 peran, 1 lajur bersama\]

Dari halaman Favorit, item dibuka ke Detail listing untuk memuat harga terbaru. Panah antar kotak memakai `Navigator.push`, kecuali halaman Favorit yang dibuka dengan `Get.toNamed`.

## Progres dan alur yang masih kurang

Tiga dari sepuluh langkah urutan build sudah ditulis: fondasi service, auth, serta katalog + detail. Login sudah teruji ke backend lokal; katalog baru teruji parsing-nya karena database lokal kosong dan koneksi Supabase belum diisi.

| No | Langkah | Status | Catatan |
| --- | --- | --- | --- |
| 1 | `api_service` + `session_service` | Selesai |  |
| 2 | Splash, login, register, MainShell, logout | Selesai | Logout sementara di AppBar; layar Profil belum ada |
| 3 | Katalog + detail + pencarian | Ditulis, belum teruji dengan data asli | Menunggu `SUPABASE_DATABASE_URL` di `.env` backend |
| 3b | Cache katalog di Hive ("Data offline") | Belum | Tingkat 1 |
| 3c | **Favorit + GetX (baru)** | Belum | Menunggu persetujuan draf |
| 4 | Beli Sekarang + daftar & detail pesanan pembeli | Belum | Tombol Beli masih placeholder |
| 5 | Lokasi: jarak ke gudang, filter radius, lokasi gudang saat register | Belum |  |
| 6 | Notifikasi immediate + scheduled + inbox lonceng | Belum |  |
| 7 | Shake-to-refresh | Belum | Pindah ke Tingkat 2: sensor tidak ada di Modul I–VIII |
| 8 | Penjual: upload faktur OCR → draft → rekomendasi harga → terbitkan | Belum | Upload gambar butuh `POST /products/upload-image`, padahal `/products` dilarang di CLAUDE.md |
| 9 | Penjual: stok + pesanan masuk + ubah status | Belum |  |
| 10 | Tingkat 2: game, filter lanjutan, ketuk pop-up membuka halaman, polish | Belum |  |

**Alur yang belum tertutup di aplikasi saat ini:**

- Layar Profil (data `ambilProfil`, tombol logout pindah ke sini).
- Penanganan "Sesi berakhir" (401) di layar yang butuh login: hapus sesi lalu `pushAndRemoveUntil` ke Login.
- Pesan error backend masih berbahasa Inggris (misalnya email sudah terdaftar).
- `Navigator.pop` eksplisit belum dipakai (dibutuhkan untuk bukti Modul IV).
- `GridView` belum dipakai (bukti Modul II).
- Dasbor penjual masih placeholder.

## Perlu dikonfirmasi

Empat pertanyaan pertama sebaiknya ditanyakan ke asisten praktikum karena menentukan penilaian; sisanya keputusan pemilik proyek.

- [ ] Ke asisten: apakah notifikasi cukup Local Notification (immediate + scheduled), atau push dari server (FCM) diwajibkan?
- [ ] Disetujui: GetX dipakai sebagian aplikasi
- [ ] Disetujui: Hive memakai `TypeAdapter` + `build_runner` seperti Modul VI
- [ ] Disetujui: sensor (shake) pindah ke Tingkat 2, karena tidak ada di Modul I–VIII
- [ ] Disetujui: perubahan CLAUDE.md (izinkan `get`, `hive_generator`, `build_runner`; folder `controllers/`, `bindings/`, `routes/`)
- [ ] Disetujui: Favorit masuk Tingkat 1 (dikerjakan setelah katalog)
- [ ] Disetujui: `POST /products/upload-image` boleh dipakai untuk upload gambar produk penjual
- [ ] Pemilik proyek: isi `SUPABASE_DATABASE_URL` di `.env` backend agar katalog bisa diuji dengan data asli
