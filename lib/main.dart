import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/favorit_binding.dart';
import 'routes/app_pages.dart';
import 'screens/auth/splash_screen.dart';
import 'services/local_db_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Wajib sebelum memakai plugin (SharedPreferences, Hive, nanti notifikasi).
  WidgetsFlutterBinding.ensureInitialized();
  // Hive: init, daftarkan adapter, buka box (Modul VI).
  await LocalDbService.init();
  // Inisialisasi notifikasi ditambahkan di langkah notifikasi.
  runApp(const RecoveraApp());
}

class RecoveraApp extends StatelessWidget {
  const RecoveraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp (Modul VIII) menggantikan MaterialApp supaya fitur GetX
    // (Get.toNamed, Binding) berjalan. Navigator.push biasa tetap bisa dipakai.
    return GetMaterialApp(
      title: 'Recovera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      initialBinding: FavoritBinding(),
      getPages: AppPages.halaman,
      home: const SplashScreen(),
    );
  }
}
