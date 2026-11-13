import 'package:get/get.dart';

import '../models/favorit_model.dart';
import '../services/local_db_service.dart';

// FavoritController (GetX, Modul VIII): menyimpan daftar favorit secara terpusat.
// Dipakai di kartu katalog, halaman detail, badge AppBar, dan halaman Favorit.
// Karena daftarFavorit reaktif (.obs), semua widget yang membungkusnya dengan
// Obx ikut berubah otomatis -- tanpa setState dan tanpa mengoper data antar layar.
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

  Future<void> hapus(int idListing) async {
    await LocalDbService.hapusFavorit(idListing);
    daftarFavorit.removeWhere((favorit) => favorit.idListing == idListing);
  }
}
