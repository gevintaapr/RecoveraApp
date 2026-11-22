import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorit_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../buyer/catalog_screen.dart';
import '../seller/dashboard_screen.dart';
import '../seller/stock_screen.dart';
import 'notification_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

// Kerangka utama setelah login: BottomNavigationBar dengan 3 tab per peran.
// Tombol Keluar ada di tab Profil. (Mini game sengaja tidak dibuat.)
class MainShell extends StatefulWidget {
  final String peran; // 'seller' atau 'buyer', dikirim dari login/register/splash

  const MainShell({super.key, required this.peran});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final NotifikasiController notifikasiController = Get.find<NotifikasiController>();

  // Pemicu cek notifikasi server (tanpa FCM, tanpa Timer):
  // sekali saat shell dibuka. Notifikasi baru (mis. "Pesanan Baru Masuk!"
  // untuk penjual) langsung muncul sebagai pop-up, badge lonceng diperbarui.
  @override
  void initState() {
    super.initState();
    notifikasiController.cekDiLatar();
  }

  // Pemicu tambahan: setiap pindah tab di BottomNavigationBar.
  void _pindahTab(int indeks) {
    setState(() => _selectedIndex = indeks);
    notifikasiController.cekDiLatar();
  }

  bool get isPenjual => widget.peran == 'seller';

  // Judul tab sesuai peran (panduan 3.2 dan 3.3).
  List<String> get _judulTab => isPenjual
      ? ['Dasbor', 'Stok', 'Profil']
      : ['Katalog', 'Pesanan', 'Profil'];

  List<IconData> get _ikonTab => isPenjual
      ? [Icons.dashboard_outlined, Icons.inventory_2_outlined, Icons.person_outline]
      : [Icons.storefront_outlined, Icons.receipt_long_outlined, Icons.person_outline];

  // Array halaman: yang tampil = _pages[_selectedIndex].
  List<Widget> get _pages => isPenjual
      ? const [
          DashboardScreen(),
          StockScreen(),
          ProfileScreen(),
        ]
      : const [
          CatalogScreen(),
          OrdersScreen(isPenjual: false),
          ProfileScreen(),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judulTab[_selectedIndex]),
        actions: [
          // Ikon Favorit + badge jumlah, hanya untuk pembeli.
          if (!isPenjual) const _IkonFavorit(),
          const _IkonNotifikasi(),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.warnaUtama,
        onTap: _pindahTab,
        items: List.generate(
          _judulTab.length,
          (i) => BottomNavigationBarItem(icon: Icon(_ikonTab[i]), label: _judulTab[i]),
        ),
      ),
    );
  }
}

// Ikon hati di AppBar dengan badge jumlah favorit.
// Get.find mengambil controller yang sama dengan kartu katalog,
// jadi angka badge ikut berubah saat hati diketuk di mana pun (Obx).
// Ketuk -> named route GetX ke halaman Favorit.
class _IkonFavorit extends StatelessWidget {
  const _IkonFavorit();

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();

    return IconButton(
      tooltip: 'Favorit',
      onPressed: () => Get.toNamed(AppRoutes.favorit),
      icon: Obx(() => Badge(
            isLabelVisible: favoritController.jumlahFavorit > 0,
            label: Text('${favoritController.jumlahFavorit}'),
            child: const Icon(Icons.favorite_border),
          )),
    );
  }
}

// Ikon lonceng + badge jumlah belum dibaca (kedua peran).
// Angka dari NotifikasiController (Obx), berkurang otomatis saat notifikasi dibaca.
// Ketuk -> Navigator.push ke halaman Notifikasi (Modul IV).
class _IkonNotifikasi extends StatelessWidget {
  const _IkonNotifikasi();

  @override
  Widget build(BuildContext context) {
    final NotifikasiController notifikasiController = Get.find<NotifikasiController>();

    return IconButton(
      tooltip: 'Notifikasi',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      ),
      icon: Obx(() => Badge(
            isLabelVisible: notifikasiController.jumlahBelumDibaca.value > 0,
            label: Text('${notifikasiController.jumlahBelumDibaca.value}'),
            child: const Icon(Icons.notifications_none),
          )),
    );
  }
}
