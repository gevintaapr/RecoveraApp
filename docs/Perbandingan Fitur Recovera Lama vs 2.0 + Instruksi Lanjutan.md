# Perbandingan Fitur Recovera Lama vs Recovera 2.0 + Instruksi Lanjutan

Tanggal: 22 November 2026. Dibandingkan: `../recovera/lib` (proyek lama, hanya baca) dan `lib/` (Recovera 2.0).

Keinginan pemilik proyek: **fitur yang dipertahankan harus punya alur dan cara kerja yang sama dengan Recovera lama**, hanya ditulis ulang mengikuti aturan `CLAUDE.md` (Modul I–VIII, `setState`, `http`, `ApiService`, dan seterusnya). Contoh yang sudah dikerjakan: harga lelang di katalog/detail kini "bergerak" (countdown hidup + harga baru diambil dari server saat countdown habis).

---

## 1. Status saat dokumen ini ditulis

- Tingkat 1 selesai ditulis dan `flutter analyze` bersih; **belum diuji di HP dengan backend**.
- Sudah ada: splash, login, register, MainShell (3 tab per peran), katalog + cache Hive, detail + Beli Sekarang, favorit (Hive + GetX), pesanan, lokasi/jarak, notifikasi (immediate, terjadwal, inbox, pop-up server), upload faktur OCR → form → rekomendasi harga → terbitkan, draft Hive, dasbor, stok, detail stok, ubah status pesanan, profil, shake-to-refresh (`sensor_service`), countdown harga (`widgets/price_countdown.dart`).
- **Mini game dihapus** atas keputusan pemilik proyek (sudah dicatat di CLAUDE.md, "Fitur yang sengaja dibuang").

---

## 2. Tabel perbandingan per fitur

Keterangan status:
- **Sama**: alurnya sudah setara.
- **Beda, bisa disamakan**: kerjakan (lihat bagian 3).
- **Beda, perlu izin**: butuh endpoint/pola yang belum diizinkan CLAUDE.md. Tanyakan ke pemilik proyek dulu.
- **Sengaja beda**: di proyek lama palsu/dummy atau fiturnya dibuang. Jangan disamakan.

### 2.1 Kerangka & auth

| Bagian | Recovera lama | Recovera 2.0 | Status |
|---|---|---|---|
| Splash → cek sesi | Splash → `/home` atau `/welcome` | Splash → MainShell atau Login | Sama (tanpa Welcome) |
| Layar Welcome (pilih peran) | Ada, ilustrasi + tombol Daftar/Masuk | Tidak ada; peran dipilih di Register | Sengaja beda (tidak ada di daftar layar CLAUDE.md) |
| Login | Email + password, Google/Facebook, biometrik | Email + password | Sengaja beda (sosial & biometrik dibuang) |
| Register | Nama, email, password, dropdown peran | Sama + data usaha + lokasi gudang | Sama |
| Bottom nav penjual | Beranda · Stok · **Tambah** (tombol tengah → upload) · Game · Profil | Dasbor · Stok · Profil; tombol Upload Stok = FAB di Stok | Beda, bisa disamakan (T9) |
| Bottom nav pembeli | Beranda · Riwayat · Game · Profil | Katalog · Pesanan · Profil | Sama (Game dibuang) |
| Tombol back di tab selain pertama | Kembali ke tab pertama dulu (`PopScope`) | Langsung keluar aplikasi | Beda, bisa disamakan (T9) |
| Header per layar | Tiap layar punya header sendiri (sapaan, ikon riwayat & lonceng) | Satu AppBar di MainShell (ikon favorit + lonceng) | Beda, bisa disamakan sebagian (T2, T5) |

### 2.2 Katalog pembeli (`home_screen` lama ↔ `buyer/catalog_screen`)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Sapaan "Halo, {nama}" + lokasi pengiriman | Ada di header | Tidak ada | Beda, bisa disamakan (T2) |
| Pencarian | "Cari produk pangan, distributor, kota..." | Ada | Sama |
| Chip kategori di bawah pencarian | Ada (`Semua` + kategori) | Tidak ada | Beda, bisa disamakan (T2), server menerima `category` |
| Filter bottom sheet | Kategori, jarak (Semua / ≤5 / <15 / ≤30 / ≤50 km, bawaan 15), sisa hari (≤14 / ≤30 / ≤60), urutan | Hanya pilihan radius (`pilihan_radius`) | Beda, bisa disamakan (T2), widget `filter_sheet` sudah direncanakan CLAUDE.md |
| Urutan | Terdekat, Termurah, Segera kedaluwarsa, Diskon tertinggi | Tidak ada | Beda, bisa disamakan (T2), server menerima `sort=nearest|cheapest|expiring_soon` |
| Pil filter aktif (bisa dihapus satu-satu) | Ada | Tidak ada | Beda, bisa disamakan (T2) |
| Judul bagian "Rekomendasi Terdekat (n)" | Ada | Tidak ada | Beda, bisa disamakan (T2) |
| Kartu produk | Nama perusahaan, nama produk, merek, jarak • kota, harga `/ satuan`, harga coret, badge sisa hari (merah bila mendesak), badge diskon & penyimpanan di gambar, tombol panah | Nama, penjual, jarak, harga, coret, diskon, sisa hari, **countdown**, tombol favorit | Sebagian sama (T2: tambah kota, `/ satuan`, badge mendesak, badge diskon di gambar) |
| Skor kecocokan (match score) | Badge persen | Tidak ada | Perlu izin (data `match_score` hanya dari AI matching; cek apakah `GET /listings` mengirimnya) |
| Shake-to-refresh | Ada | Ada | Sama |
| Offline | Banner "Mode Offline: data cache" | Label "Data offline" dari Hive | Sama |
| Data dummy saat server gagal | Menampilkan `dummyListings` | Menampilkan cache Hive atau error | Sengaja beda (dummy tidak jujur) |
| Chatbot "Rera" (FAB) | Ada | Tidak ada | Sengaja beda (`/ai/chat` tidak diizinkan) |

### 2.3 Detail produk & beli (`product_detail_screen` lama ↔ `buyer/listing_detail_screen`)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Countdown harga turun | Berdetak tiap detik, **tetapi angkanya palsu** (selalu 15464 detik) | Berdetak tiap detik dari `next_drop_at`; habis → harga baru dari server | Sama (2.0 lebih benar) |
| "Tier 2 of 4", "Target Harga Tier 3: Rp 8.250", "Sisa 36 Jam di Tier Ini" | Teks tetap (dummy) | Tidak ada | Sengaja beda (angka palsu); boleh diganti info asli: harga minimum + jadwal turun |
| Spesifikasi batch | Minimal pembelian, kedaluwarsa, metode pengambilan, suhu penyimpanan | Stok, kategori, kedaluwarsa, lelang berakhir, penjual, kota, jarak | Beda, bisa disamakan (T1: tambah nomor batch, suhu penyimpanan bila dikirim server, metode "Ambil di gudang") |
| Pilih jumlah | Stepper +/- dengan kolom angka di bar bawah (minimal 5) | Dialog jumlah (`dialog_beli`) | Beda, bisa disamakan (T1). Minimal 5 hanya aturan klien lama; gunakan minimal 1 kecuali pemilik proyek minta |
| Konfirmasi sebelum beli | Bottom sheet ringkasan (produk, jumlah, harga satuan terkini, total) | Langsung dari dialog jumlah | Beda, bisa disamakan (T1) |
| Verifikasi biometrik | Wajib | Tidak ada | Sengaja beda (dibuang) |
| Proses bayar | Overlay animasi langkah pembayaran | Dialog loading | Sama secara fungsi (boleh dipoles, tanpa jeda palsu) |
| Setelah berhasil | Dialog sukses berisi faktur → tutup → kembali | Notifikasi + snackbar → pindah ke detail pesanan | Beda, bisa disamakan (T1: tampilkan dialog faktur dulu, tombol "Lihat Pesanan") |
| Pesanan palsu saat API gagal | Membuat `mockOrder` | Menampilkan pesan error | Sengaja beda |
| Konversi mata uang & zona waktu, ESG | Ada | Tidak ada | Sengaja beda (dibuang) |

### 2.4 Pesanan pembeli (`buyer_transaction_screen` lama ↔ `shared/orders_screen` + `buyer/order_detail_screen`)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Judul "Riwayat Transaksi" + chip status (Semua / Menunggu / Siap diambil / Selesai / Dibatalkan) | Ada | Daftar tanpa filter | Beda, bisa disamakan (T3) |
| Kartu pesanan | Gambar, nama, status, total tagihan, petunjuk lokasi pengambilan, tombol "Rincian Faktur" | Nama, jumlah × harga, penjual, tanggal, total, status | Beda, bisa disamakan (T3) |
| Dialog "Faktur Transaksi B2B" | Ada | Detail pesanan (layar) | Beda, bisa disamakan (T3) |
| "Hubungi Seller" (kirim pengingat ke penjual) | `POST /orders/{id}/remind-seller` | Tidak ada | Perlu izin (endpoint belum ada di daftar CLAUDE.md) |
| Gambar produk | Ada | Tidak ada (`urlGambar` sudah ada di `OrderModel`) | Beda, bisa disamakan (T3) |

### 2.5 Penjual: dasbor (`seller_dashboard_screen` lama ↔ `seller/dashboard_screen`)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Header nama perusahaan + gudang | Ada | AppBar "Dasbor" | Beda, bisa disamakan (T5), nama perusahaan dari `ambilProfil()` |
| Kotak ringkasan | Stok aktif, transaksi bulan ini, segera kedaluwarsa, sertifikat ESG | Listing aktif, draft, perlu diproses, pesanan selesai (GridView) | Beda, bisa disamakan (T5: ganti jadi stok aktif, transaksi bulan ini, segera kedaluwarsa, perlu diproses; ESG dibuang) |
| Aksi cepat | Upload Stok, Inventaris, Sertifikat ESG, Pesanan | Tidak ada | Beda, bisa disamakan (T5, tanpa ESG) |
| "Stok Mendekati Kedaluwarsa" | Daftar | Tidak ada | Beda, bisa disamakan (T5, hitung dari inventaris: aktif & sisa hari ≤ 14) |
| "Pesanan Menunggu Tindakan" dengan tombol **Siapkan / Selesaikan langsung di kartu** | Ada | Daftar; ubah status harus masuk detail | Beda, bisa disamakan (T4) |
| Data dari `GET /listings/seller/dashboard` | Ya | Dihitung dari inventaris + pesanan | Sengaja beda (endpoint tidak diizinkan); hasil tampilan disamakan |
| Refresh otomatis tiap 5 menit (`Timer`) | Ada | Tarik ke bawah | Sengaja beda (tidak perlu `Timer` tambahan) |

### 2.6 Penjual: pesanan masuk (`seller_order_screen` lama)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Layar "Kelola Pesanan Masuk" dengan kotak ringkasan + chip status | Ada | `OrdersScreen(isPenjual: true)` polos | Beda, bisa disamakan (T4) |
| Tombol di kartu: "Siapkan & Tandai Siap Diambil", "Konfirmasi Telah Diambil (Handover)" | Ada | Di detail pesanan | Beda, bisa disamakan (T4) |
| "Ingatkan Pembeli untuk Ambil" | `POST /orders/{id}/remind-buyer` | Tidak ada | Perlu izin |
| Dialog "Faktur Penjualan B2B" | Ada | Tidak ada | Beda, bisa disamakan (T4) |

### 2.7 Penjual: stok & detail stok

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Judul "Stok Saya" + pencarian "Cari stok..." | Ada | Tanpa pencarian | Beda, bisa disamakan (T6, saring di HP) |
| Tab Semua / Aktif / Terjual / Expired | Ada | Chip Semua / Draft / Aktif / Habis / Kedaluwarsa | Sama (2.0 menambah Draft) |
| Kartu stok dengan "Proses Saat Ini" | Ada | `ListingCard` mode penjual + status | Sama secara isi |
| Tombol Upload Stok + reload saat kembali | Ada | Ada | Sama |
| Detail: struktur harga (normal, harga mulai lelang, minimum) | Ada | Normal, sekarang, minimum | Beda, bisa disamakan (T6: tambah nomor batch & harga mulai) |
| Detail draft: "Lanjutkan Upload & Validasi" | Membuka alur upload dengan draft itu | "Lihat Rekomendasi Harga" → Terbitkan | Perlu izin bila ingin mengedit isi draft (`PATCH /listings/seller/inventory/{id}`) |
| Detail draft: "Hapus Draf Produk" | `DELETE /listings/seller/inventory/{id}` | Tidak ada | Perlu izin |

### 2.8 Penjual: upload stok (`upload_stock_flow_screen` lama ↔ `seller/upload_invoice_screen` + `seller/listing_form_screen`)

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Indikator langkah 1 Produk · 2 Validasi · 3 Harga · 4 Review | Ada | Dua layar tanpa indikator | Beda, bisa disamakan (T7: indikator 1 Faktur · 2 Data · 3 Harga) |
| Foto faktur OCR + foto produk | Di satu layar langkah 1 | Layar faktur lalu form | Sama secara alur |
| Langkah Validasi (animasi progres) | Animasi bar + `Timer` | Validasi form + server | Sengaja beda (animasi palsu) |
| Langkah Harga: penjual bisa **mengubah harga awal** (mode manual) dan melihat peringatan bila di luar rentang | Ada, lalu `updateDraft(start_price)` | Hanya melihat saran, lalu terbitkan | Perlu izin (butuh `PATCH /listings/seller/inventory/{id}`) |
| Langkah Review sebelum terbit | Ringkasan semua data | Kartu rekomendasi + Terbitkan | Beda, bisa disamakan (T7) |
| Draft lokal | Sqflite | Hive + `ValueListenableBuilder` | Sama (sesuai Modul VI) |

### 2.9 Notifikasi

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Inbox, tandai dibaca | Ada | Ada | Sama |
| Waktu relatif ("Baru saja", "5 menit lalu") | Ada | Tanggal + jam | Beda, bisa disamakan (T8) |
| Ketuk notifikasi → halaman sesuai jenis (`type`) | Pesanan → pesanan, `new_listing` → detail listing | Hanya pesanan → detail pesanan | Beda, bisa disamakan (T8) |
| Ketuk pop-up di status bar → buka halaman | Ada (FCM) | Belum | Beda, bisa disamakan (T8, Tingkat 2 "ketuk pop-up membuka halaman") |
| Push dari server saat aplikasi tertutup | FCM | Hanya saat aplikasi dibuka / di-refresh | Sengaja beda (FCM dibuang; sebutkan jujur saat presentasi) |

### 2.10 Profil

| Bagian | Lama | 2.0 | Status |
|---|---|---|---|
| Kartu profil, peran, kota, badge "Terverifikasi" | Ada | Avatar huruf, nama, email, peran, info usaha | Sama secara isi |
| Logout dengan konfirmasi | Ada | Ada | Sama |
| Ubah foto profil (kamera/galeri, disimpan di HP) | Ada | Tidak ada | Perlu izin (bukan fitur wajib) |
| Ubah info usaha, kelola lokasi | `PATCH /profile` | Tidak ada | Sengaja beda (`PATCH /profile` dilarang) |
| Biometrik, mata uang, zona waktu, Saran & Kesan | Ada | Tidak ada | Sengaja beda (dibuang) |

---

## 3. Instruksi untuk agent berikutnya

### 3.1 Wajib dibaca dulu

1. `CLAUDE.md` (aturan proyek; menimpa semua kebiasaan bawaan).
2. Dokumen ini.
3. File proyek lama yang disebut di tiap tugas, **hanya sebagai contoh alur dan tata letak**. Jangan menyalin Provider, Dio, repository, sqflite, `GoogleFonts`, `AppColors`, atau angka ukuran langsung.

### 3.2 Aturan kerja

- Kerjakan **satu tugas per permintaan pemilik proyek**, sesuai urutan di bawah. Setelah selesai, jelaskan alurnya singkat (layar menampilkan apa, data dari method `ApiService` mana, kapan `setState`), lalu jalankan `flutter analyze` sampai bersih.
- Tugas bertanda **[PERLU IZIN]**: tanyakan dulu ke pemilik proyek; jangan dikerjakan diam-diam.
- Jangan menambahkan apa pun dari kolom "Sengaja beda".
- Semua warna, ukuran font, jarak, dan radius hanya dari `theme/app_theme.dart`; tambahkan konstanta baru di sana bila perlu.
- Harga lelang tetap dihitung server. Jangan menghitung ulang harga di HP.
- Setiap aksi yang butuh waktu wajib punya buffer (`PrimaryButton(sedangMemuat: ...)` atau `tampilkanDialogMemuat`).
- Pola penanganan galat yang sudah dipakai: `pesan == 'Sesi berakhir'` → `kembaliKeLogin(context)`.
- File lewat ±250 baris → pecah ke `widgets/`.

### 3.3 Daftar tugas (urut)

**T1 — Detail produk & alur beli seperti lama** (`buyer/listing_detail_screen.dart`, `widgets/dialog_beli.dart`)
- Bar bawah tetap: stepper jumlah (−, kolom angka, +), batas 1..stok, plus tombol "Beli Sekarang". Rujukan: `_decrementQty`, `_incrementQty`, `_buildStickyBottomBar` di `product_detail_screen.dart` lama.
- Ketuk Beli → bottom sheet konfirmasi (produk, jumlah, harga satuan saat ini, total; catatan "harga dikunci server saat dibeli") → tombol Konfirmasi → dialog loading → `ApiService.beliSekarang`. Rujukan: `_buildConfirmationBottomSheet`.
- Berhasil → notifikasi (sudah ada) → dialog "Pembelian Berhasil" berisi faktur ringkas (nomor pesanan, produk, jumlah, harga satuan final, total, alamat pengambilan) dengan tombol "Lihat Pesanan" (`pushReplacement` ke `OrderDetailScreen`) dan "Tutup". Rujukan: `_showOrderSuccessDialog`.
- Tambah baris spesifikasi: nomor batch, penyimpanan, "Metode: Ambil di gudang". Bila `ListingModel` belum punya field-nya, tambahkan dari JSON (`batch_number`, `product.storage_type`). Field baru di model ber-`@HiveType` wajib `@HiveField` nomor baru, lalu jalankan `dart run build_runner build --delete-conflicting-outputs`.

**T2 — Katalog seperti lama + filter lanjutan & urutan** (`buyer/catalog_screen.dart`, `widgets/filter_sheet.dart` baru, `widgets/listing_card.dart`, `ApiService.ambilDaftarListing`)
- Header di atas pencarian: "Halo, {nama}" (`SessionService.ambilNamaPengguna`) + baris lokasi (kota/jarak status GPS).
- Chip kategori horizontal (Semua + kategori yang sama dengan `FormDataProduk.daftarKategori`) → parameter `category`.
- `filter_sheet` (bottom sheet): kategori, jarak (Semua / 5 / 15 / 30 / 50 km), sisa umur simpan (Semua / ≤14 / ≤30 / ≤60 hari), urutan (Terdekat `nearest`, Termurah `cheapest`, Segera kedaluwarsa `expiring_soon`). Server **tidak** punya filter "maksimal hari" (hanya `min_days`), jadi saring ≤N hari di HP memakai `sisaHari`. "Diskon tertinggi" diurutkan di HP memakai `diskonPersen`. Ganti `pilihan_radius` dengan sheet ini.
- Ikon filter dengan angka jumlah filter aktif + baris pil filter aktif (ketuk × untuk menghapus satu filter).
- Judul "Rekomendasi Terdekat" + jumlah hasil.
- Kartu: tambah kota gudang setelah jarak, harga `/ satuan`, badge sisa hari berwarna peringatan bila ≤ 7 hari, badge diskon di pojok gambar. Pertahankan countdown dan tombol favorit.
- Rujukan: `_buildFixedWaveHeader`, `_buildCategoryChips`, `_showFilterBottomSheet`, `_buildActiveFiltersBar`, `_buildRecommendationHeader` di `home_screen.dart`; `product_card.dart`; `filter_bottom_sheet.dart`.

**T3 — Riwayat pesanan pembeli seperti lama** (`shared/orders_screen.dart`, `widgets/kartu_pesanan.dart`, `buyer/order_detail_screen.dart`)
- Chip status di atas daftar: Semua / Menunggu disiapkan (`paid`) / Siap diambil (`in_progress`) / Selesai (`completed`), disaring di HP.
- Kartu: gambar produk (`urlGambar`), nama, status, total tagihan, dan untuk `in_progress` baris "Ambil di: {alamat gudang}".
- Detail pesanan: bagian "Rincian Faktur" (nomor pesanan, produk, jumlah, harga satuan final, biaya platform Rp0, total).
- [PERLU IZIN] Tombol "Ingatkan Penjual" → `POST /orders/{id}/remind-seller` (status `paid`, jeda 3 jam dari server).

**T4 — Pesanan masuk penjual seperti lama** (`seller/dashboard_screen.dart`, `shared/orders_screen.dart`, `widgets/kartu_pesanan.dart`)
- Kartu pesanan versi penjual punya tombol aksi langsung: `paid` → "Siapkan & Tandai Siap Diambil"; `in_progress` → "Konfirmasi Telah Diambil". Pakai `tampilkanDialogMemuat` + `ApiService.ubahStatusPesanan`, lalu muat ulang.
- Layar "Semua Pesanan Masuk": kotak ringkasan (menunggu, siap diambil, selesai) + chip status.
- [PERLU IZIN] "Ingatkan Pembeli untuk Ambil" → `POST /orders/{id}/remind-buyer`.

**T5 — Dasbor penjual seperti lama** (`seller/dashboard_screen.dart`)
- Header: nama perusahaan + kota gudang dari `ApiService.ambilProfil()` (gabungkan ke `_DataDasbor`).
- Kotak ringkasan (GridView tetap): Stok aktif, Transaksi bulan ini (pesanan bulan berjalan), Segera kedaluwarsa (aktif & `sisaHari` ≤ 14), Perlu diproses.
- Bar aksi cepat: Upload Stok (→ `UploadInvoiceScreen`), Stok (pindah ke tab Stok lewat callback dari MainShell), Pesanan (→ semua pesanan).
- Kartu "Stok Mendekati Kedaluwarsa" (maksimal 3, ketuk → `SellerListingDetailScreen`).
- Bagian "Pesanan Menunggu Tindakan" memakai kartu dengan tombol dari T4.

**T6 — Stok & detail stok seperti lama** (`seller/stock_screen.dart`, `seller/listing_detail_screen.dart`)
- Kolom pencarian "Cari stok..." (saring nama/merek di HP).
- Detail: bagian "Struktur Harga" (harga normal, harga mulai lelang, harga sekarang, batas minimum) dan nomor batch.
- [PERLU IZIN] "Hapus Draf Produk" → `DELETE /listings/seller/inventory/{id}`.
- [PERLU IZIN] "Lanjutkan Upload" untuk draft (edit isi draft) → `PATCH /listings/seller/inventory/{id}`.

**T7 — Indikator langkah & review upload** (`seller/upload_invoice_screen.dart`, `seller/listing_form_screen.dart`)
- Indikator langkah di atas kedua layar: 1 Faktur · 2 Data Produk · 3 Harga & Terbit (widget kecil baru di `widgets/`).
- Tahap Harga: tampilkan ringkasan review (foto, nama, jumlah, kedaluwarsa, harga normal, minimum) di atas kartu rekomendasi sebelum tombol Terbitkan.
- [PERLU IZIN] Mode ubah harga awal manual dengan peringatan rentang (perlu `PATCH /listings/seller/inventory/{id}` dengan `start_price`). Rujukan: langkah 3 di `upload_stock_flow_screen.dart`.

**T8 — Notifikasi: buka halaman sesuai jenis** (`shared/notification_screen.dart`, `models/notification_model.dart`, `services/notification_service.dart`)
- `NotificationModel` sudah menyimpan `tipe` dan `idPesanan`; tambahkan `idListing` dari `data.listing_id`. Ketuk: ada `order_id` → `OrderDetailScreen(isPenjual: ...)`; ada `listing_id` dan peran pembeli → `ListingDetailScreen`; penjual → `SellerListingDetailScreen`.
- Waktu relatif di daftar ("Baru saja", "5 menit lalu", "2 jam lalu", lalu tanggal).
- Ketuk pop-up di status bar membuka halaman yang sama: kirim `payload` (mis. `order:12` / `listing:5`) di `show`, tangani di `onDidReceiveNotificationResponse` saat `initialize`, navigasi lewat `Get.key`/`navigatorKey` dari `GetMaterialApp`. Pola ini di luar modul, jadi wajib diberi komentar `CATATAN`.

**T9 — Kerangka seperti lama** (`shared/main_shell.dart`)
- Tombol back di tab selain pertama → kembali ke tab pertama (`PopScope`), seperti `main_shell.dart` lama.
- Opsional, tanyakan dulu: tombol tengah "Tambah" di bottom nav penjual (membuka `UploadInvoiceScreen`) sebagai ganti FAB di Stok.

### 3.4 Keputusan yang masih ditunggu dari pemilik proyek

1. **Cek notifikasi saat pindah tab** (`MainShell._pindahTab` memanggil `cekDiLatar()`). Bertentangan dengan CLAUDE.md ("dipanggil sekali di initState MainShell"). Pilihan: hapus, atau ubah CLAUDE.md agar mengizinkannya. Jangan diubah sebelum ada jawaban.
2. Izin endpoint tambahan: `remind-seller`, `remind-buyer`, `DELETE` draft, `PATCH` draft (`start_price` dan isi draft).
3. Foto profil lokal (kamera/galeri), opsional.
4. Tombol tengah "Tambah" di nav penjual, opsional.

### 3.5 Cara memastikan hasil

- `flutter analyze` → "No issues found!".
- Uji di HP (kabel USB): `adb reverse tcp:8000 tcp:8000`, backend dengan `TIME_SCALE` agar harga turun cepat.
- Alur demo yang harus tetap jalan: pembeli katalog → detail → beli → pesanan; penjual upload faktur → terbitkan → stok → pesanan masuk → ubah status → pembeli melihat status berubah; notifikasi muncul; logout.
