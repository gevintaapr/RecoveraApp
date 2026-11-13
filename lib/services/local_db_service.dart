import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorit_model.dart';

// LocalDbService: SATU-SATUNYA tempat yang menyentuh Hive (Modul VI).
// Screen dan controller memanggil method di sini, tidak membuka box sendiri.
class LocalDbService {
  static const String _namaBoxFavorit = 'favorit_listing';

  // Dipanggil sekali di main.dart sebelum runApp.
  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapter hasil build_runner (favorit_model.g.dart).
    Hive.registerAdapter(FavoritModelAdapter());
    await Hive.openBox<FavoritModel>(_namaBoxFavorit);
  }

  static Box<FavoritModel> get _boxFavorit =>
      Hive.box<FavoritModel>(_namaBoxFavorit);

  // ===== FAVORIT =====

  // Semua favorit, yang terbaru disimpan tampil paling atas.
  static List<FavoritModel> ambilSemuaFavorit() {
    final List<FavoritModel> daftar = _boxFavorit.values.toList();
    daftar.sort((a, b) => b.waktuDisimpan.compareTo(a.waktuDisimpan));
    return daftar;
  }

  // Kunci = id listing, jadi listing yang sama tidak tersimpan dua kali.
  static Future<void> simpanFavorit(FavoritModel favorit) async {
    await _boxFavorit.put(favorit.idListing, favorit);
  }

  static Future<void> hapusFavorit(int idListing) async {
    await _boxFavorit.delete(idListing);
  }

  // (cache katalog, draft penjual, dan skor game ditambahkan di langkahnya)
}
