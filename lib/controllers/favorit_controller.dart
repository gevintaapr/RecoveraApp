import 'package:get/get.dart';

import '../models/favorit_model.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';

// FavoritController (GetX, Modul VIII): menyimpan daftar favorit secara terpusat.
// Dipakai di kartu katalog, halaman detail, badge AppBar, dan halaman Favorit.
// Karena daftarFavorit reaktif (.obs), semua widget yang membungkusnya dengan
// Obx ikut berubah otomatis -- tanpa setState dan tanpa mengoper data antar layar.
// Status pengingat lelang (lonceng) juga disimpan di sini, jadi lonceng di halaman
// Favorit dan tombol "Ingatkan saya" di detail selalu sama.
class FavoritController extends GetxController {
  final RxList<FavoritModel> daftarFavorit = <FavoritModel>[].obs;

  // Lifecycle GetX: dipanggil sekali saat controller dibuat.
  @override
  void onInit() {
    super.onInit();
    muatFavorit();
  }

  // Ambil isi Hive ke daftar reaktif.
  void muatFavorit() {
    daftarFavorit.assignAll(LocalDbService.ambilSemuaFavorit());
  }

  int get jumlahFavorit => daftarFavorit.length;

  bool apakahFavorit(int idListing) {
    return daftarFavorit.any((favorit) => favorit.idListing == idListing);
  }

  // Simpan bila belum ada, hapus bila sudah ada.
  // Mengembalikan true bila sekarang tersimpan (untuk pesan SnackBar).
  Future<bool> toggleFavorit(FavoritModel favorit) async {
    if (apakahFavorit(favorit.idListing)) {
      await hapus(favorit.idListing);
      return false;
    }
    await LocalDbService.simpanFavorit(favorit);
    daftarFavorit.insert(0, favorit);
    return true;
  }

  // Daftar reaktif dihapus DULU, baru Hive. Urutan ini wajib untuk Dismissible
  // (geser hapus): item harus langsung hilang dari daftar pada frame yang sama.
  // Pengingat yang masih terpasang ikut dibatalkan.
  Future<void> hapus(int idListing) async {
    final FavoritModel? favorit = _cari(idListing);
    daftarFavorit.removeWhere((item) => item.idListing == idListing);
    await LocalDbService.hapusFavorit(idListing);
    if (favorit != null && favorit.pengingatAktif) {
      await NotificationService().batalkanPengingat(NotificationService.idPengingat(idListing));
    }
  }

  // ===== PENGINGAT LELANG (scheduled notification, Modul VII) =====

  bool pengingatTerjadwal(int idListing) {
    final FavoritModel? favorit = _cari(idListing);
    return favorit != null && favorit.pengingatTerjadwal;
  }

  // Pasang bila belum aktif, batalkan bila sudah aktif.
  // Mengembalikan true bila pengingat sekarang aktif.
  // Produk yang belum difavoritkan otomatis ikut disimpan ke Favorit,
  // karena status pengingat disimpan di data favorit.
  Future<bool> aturPengingat(FavoritModel favorit) async {
    final FavoritModel? tersimpan = _cari(favorit.idListing);
    final int idNotifikasi = NotificationService.idPengingat(favorit.idListing);

    if (tersimpan != null && tersimpan.pengingatTerjadwal) {
      await NotificationService().batalkanPengingat(idNotifikasi);
      await _simpan(tersimpan.salinDenganPengingat(false));
      return false;
    }

    if (!favorit.waktuPengingat.isAfter(DateTime.now())) {
      throw Exception('Lelang berakhir kurang dari 30 menit lagi.');
    }
    await NotificationService().scheduleNotification(
      id: idNotifikasi,
      title: 'Lelang segera berakhir',
      body: '${favorit.namaProduk} berakhir 30 menit lagi. Cek harganya sekarang!',
      scheduledTime: favorit.waktuPengingat,
      payload: 'listing:${favorit.idListing}', // ketuk pop-up -> buka detail listing
    );
    await _simpan((tersimpan ?? favorit).salinDenganPengingat(true));
    return true;
  }

  // Simpan ke Hive lalu perbarui daftar reaktif (ganti item lama atau tambah di atas).
  Future<void> _simpan(FavoritModel favorit) async {
    await LocalDbService.simpanFavorit(favorit);
    final int indeks = daftarFavorit.indexWhere((item) => item.idListing == favorit.idListing);
    if (indeks == -1) {
      daftarFavorit.insert(0, favorit);
    } else {
      daftarFavorit[indeks] = favorit;
    }
  }

  FavoritModel? _cari(int idListing) {
    for (final FavoritModel favorit in daftarFavorit) {
      if (favorit.idListing == idListing) return favorit;
    }
    return null;
  }
}
