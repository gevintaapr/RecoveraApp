import 'package:get/get.dart';

import '../bindings/favorit_binding.dart';
import '../screens/buyer/favorit_screen.dart';
import 'app_routes.dart';

// Daftar named route GetX (Modul VIII). Dipasang di GetMaterialApp(getPages: ...).
// Halaman Favorit dibuka dengan Get.toNamed(AppRoutes.favorit);
// FavoritBinding menyiapkan FavoritController sebelum halaman tampil.
// Halaman lain tetap memakai Navigator.push (Modul IV).
class AppPages {
  static final List<GetPage> halaman = [
    GetPage(
      name: AppRoutes.favorit,
      page: () => const FavoritScreen(),
      binding: FavoritBinding(),
    ),
  ];
}
