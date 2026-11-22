import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';

// Binding (Modul VIII): tempat mendaftarkan controller ke GetX.
// Dipasang di dua tempat:
// 1. initialBinding di GetMaterialApp -> sudah terdaftar sejak aplikasi mulai,
//    karena katalog dan badge AppBar langsung membutuhkannya.
// 2. binding di GetPage Favorit -> menyiapkan controller sebelum halaman dibuka.
//    Bila sudah terdaftar, lazyPut kedua ini diabaikan GetX (instance tetap sama).
//
// Get.lazyPut: controller baru dibuat saat pertama kali Get.find dipanggil.
// fenix: true -> bila controller sempat dihapus GetX (mis. halaman ditutup),
// ia dibuat ulang otomatis saat dicari lagi; isinya dimuat ulang dari Hive di onInit.
class FavoritBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritController>(() => FavoritController(), fenix: true);
  }
}
