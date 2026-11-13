import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';

// Binding (Modul VIII): tempat mendaftarkan controller ke GetX.
// Dipasang sebagai initialBinding di GetMaterialApp, jadi berjalan saat aplikasi mulai.
// Memakai Get.put (bukan lazyPut) dengan permanent: true karena controller ini
// sudah dibutuhkan sejak katalog tampil dan harus tetap hidup di semua halaman.
// Widget lain cukup mengambilnya dengan Get.find<FavoritController>().
class FavoritBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FavoritController>(FavoritController(), permanent: true);
  }
}
