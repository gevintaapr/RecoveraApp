import 'package:get/get.dart';

import '../screens/buyer/favorit_screen.dart';
import 'app_routes.dart';

// Daftar named route GetX (Modul VIII). Dipasang di GetMaterialApp(getPages: ...).
// Halaman Favorit tidak butuh binding sendiri karena FavoritController
// sudah didaftarkan oleh FavoritBinding saat aplikasi mulai.
// Halaman lain tetap memakai Navigator.push (Modul IV).
class AppPages {
  static final List<GetPage> halaman = [
    GetPage(name: AppRoutes.favorit, page: () => const FavoritScreen()),
  ];
}
